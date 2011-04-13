Order.class_eval do
  def volume_discount
    line_items.map(&:volume_discount).sum
  end

  def products_line_items product
    line_items.to_a.select {|i| product.all_variant_ids.include? i.variant_id}
  end

  def line_items_dirty?
    @line_items && @line_items.any? {|i| !i.destroyed? && i.changed?}
  end

  # By default volume price is calculated based only on quantity of the current
  # order. If you want to have "Volume Customers" - people who purchase at
  # volume prices, but making multiple orders of smaller quantities you can
  # overwrite this method. You could return the total quantity of given variants
  # the customer bought in the last month. The line items volume price
  # calculation will be adjusted by that number. Like this:
  # variant_starting_quantity + current order quantity
  def variants_starting_quantity *variant_ids
    0
  end

  def update_totals_with_volume_discount
    # we might need to refresh the items
    line_items true unless line_items_dirty?
    update_totals_without_volume_discount
  end
  alias_method_chain :update_totals, :volume_discount

  def volume_user_changed?
    user_id_changed? || email_changed?
  end

  def force_volume_discount_update
    products_to_update = []

    line_items.each do |li|
      if li.variant.requires_per_product_discount?
        products_to_update << li.variant.product
      else
        li.update_volume_discount self
        li.save if li.persisted?
      end
    end

    products_to_update.uniq.each {|p| update_product_volume_discount p}

    update!
  end
  # This is required for Volume Customers
  # It updates item_total when user logs in
  before_save :force_volume_discount_update, :if => :volume_user_changed?

  def update_product_volume_discount product
    line_items true unless line_items_dirty?
    items = products_line_items(product).sort_by &:variant_id

    return if items.blank?

    starting_quantity = variants_starting_quantity *product.all_variant_ids
    quantity = items.map(&:quantity).sum
    volume_cost = product.master.total_volume_cost starting_quantity, quantity
    regular_cost = items.map(&:amount_without_volume_discount).sum
    volume_discount = volume_cost - regular_cost

    # only one item stores the discount to avoid division problems
    items.shift.update_attributes_without_callbacks \
      :volume_discount => volume_discount

    items.each do |i|
      i.update_attributes_without_callbacks :volume_discount => 0.0
    end
  end
end unless Order.instance_methods.include? :update_totals_on_user_association
