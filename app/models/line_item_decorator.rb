LineItem.class_eval do
  def update_volume_discount updated_order = nil
    self.volume_discount = 0
    self.order = updated_order if updated_order

    if variant.uses_master_discount? && new_record?
      self.price = variant.volume_prices_source.price
    end

    return if quantity < 1 || !variant.uses_volume_pricing?

    unless variant.requires_per_product_discount?
      starting_quantity = order.variants_starting_quantity(variant_id)

      volume_cost = variant.volume_prices_source.total_volume_cost \
                      starting_quantity, quantity
      self.volume_discount = volume_cost - quantity * self.price
    end
  end

  def amount_with_volume_discount
    check_update_volume_discount
    amount_without_volume_discount + self.volume_discount
  end
  alias_method_chain :amount, :volume_discount
  alias total amount

  def update_order_with_volume_discount
    if quantity > 0 && variant.requires_per_product_discount?
      order.update_product_volume_discount variant.product
    end

    update_order_without_volume_discount
  end
  alias_method_chain :update_order, :volume_discount

  private
  before_save :check_update_volume_discount
  def check_update_volume_discount
    update_volume_discount if price_changed? || quantity_changed?
  end
end unless LineItem.instance_methods.include? :amount_with_volume_discount
