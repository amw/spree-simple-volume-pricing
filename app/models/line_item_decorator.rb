LineItem.class_eval do
  before_save :check_update_volume_discount

  def update_volume_discount updated_order = nil
    self.volume_discount = 0

    return if self.quantity < 1 || variant.volume_prices.empty?

    self.order = updated_order if updated_order
    total_quantity = self.quantity + order.variant_starting_quantity(variant)
    final_price = default_price = self.price

    variant.volume_prices.each do |vp|
      break if vp.starting_quantity > total_quantity
      final_price = vp.price
    end

    self.volume_discount = self.quantity * (final_price - default_price)
  end

  def amount_with_volume_discount
    update_volume_discount
    amount_without_volume_discount + self.volume_discount
  end
  alias_method_chain :amount, :volume_discount

  private
  def check_update_volume_discount
    update_volume_discount if price_changed? || quantity_changed?
  end
end
