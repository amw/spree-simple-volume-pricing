Order.class_eval do
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

  def add_variant_with_volume_prices variant, quantity = 1
    current_item = add_variant_without_volume_prices variant, quantity
    current_item.price = variant.volume_price current_item.quantity, self
    raise ActiveRecord::RollBack unless current_item.save
    update!
  end
  alias_method_chain :add_variant, :volume_prices
end
