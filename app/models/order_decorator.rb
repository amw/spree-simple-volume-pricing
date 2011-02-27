Order.class_eval do
  def add_variant_with_volume_prices variant, quantity = 1
    current_item = add_variant_without_volume_prices variant, quantity
    current_item.price = variant.volume_price current_item.quantity, self
    raise ActiveRecord::RollBack unless current_item.save
    update!
  end
  alias_method_chain :add_variant, :volume_prices

  # By default volume price is calculated based only on quantity of the current
  # order. If you want to have "Volume Customers" - people who purchase at
  # volume prices, but making multiple orders of smaller quantities you can
  # overwrite this method. You could return the total quantity of given variant
  # the customer bought in the last month. The line items volume price
  # calculation will be adjusted by that number. Like this:
  # variant_starting_quantity + current order quantity
  def variant_starting_quantity variant
    0
  end

  # This is required for Volume Customers
  # It updates line items prices when user logs in
  def recalculate_prices_on_user_association
    if user_id_changed? || email_changed?
      line_items.each do |li|
        li.price = li.variant.volume_price li.quantity, self
        li.save
      end
    end
  end
  before_save :recalculate_prices_on_user_association
end
