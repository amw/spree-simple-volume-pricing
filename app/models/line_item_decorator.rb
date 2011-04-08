LineItem.class_eval do
  before_save :check_update_volume_discount

  def update_volume_discount updated_order = nil
    self.volume_discount = 0

    return if self.quantity < 1 || variant.volume_prices.empty?

    self.order = updated_order if updated_order
    starting_quantity = order.variant_starting_quantity(variant)

    self.volume_discount = if variant.progressive_volume_discount
      progressive_price_strategy starting_quantity
    else
      uniform_price_strategy starting_quantity
    end
  end

  def amount_with_volume_discount
    check_update_volume_discount
    amount_without_volume_discount + self.volume_discount
  end
  alias_method_chain :amount, :volume_discount
  alias total amount

  private
  def check_update_volume_discount
    update_volume_discount if price_changed? || quantity_changed?
  end

  def uniform_price_strategy starting_quantity
    total_quantity = self.quantity + starting_quantity
    final_price = default_price = self.price

    variant.volume_prices.each do |vp|
      break if vp.starting_quantity > total_quantity
      final_price = vp.price
    end

    self.quantity * (final_price - default_price)
  end

  def progressive_price_strategy units_processed
    discount = 0
    total_quantity = self.quantity + units_processed
    current_price = default_price = self.price

    variant.volume_prices.each do |vp|
      if vp.starting_quantity - 1 > units_processed
        last_unit_for_this_price = [total_quantity, vp.starting_quantity - 1].min
        items_count = last_unit_for_this_price - units_processed
        discount += items_count * (current_price - default_price)
        units_processed = last_unit_for_this_price
      end
      break if vp.starting_quantity > total_quantity
      current_price = vp.price
    end

    if total_quantity > units_processed
      items_count = total_quantity - units_processed
      discount += items_count * (current_price - default_price)
    end

    discount
  end
end
