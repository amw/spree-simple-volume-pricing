Variant.class_eval do
  has_many :volume_prices,
    :order => :starting_quantity,
    :dependent => :destroy,
    :inverse_of => :variant
  accepts_nested_attributes_for :volume_prices,
    :reject_if => :blank_volume_price,
    :allow_destroy => true

  # calculates the price based on quantity
  def volume_price quantity, order = nil
    quantity += order.variant_starting_quantity self if order

    price = self.price
    volume_prices.each do |vp|
      break if vp.starting_quantity > quantity
      price = vp.price
    end
    price
  end

  def blank_volume_price attributes
    attributes['starting_quantity'].blank? && attributes['price'].blank?
  end
end
