Variant.class_eval do
  has_many :volume_prices,
    :order => :starting_quantity,
    :dependent => :destroy,
    :inverse_of => :variant
  accepts_nested_attributes_for :volume_prices,
    :reject_if => :blank_volume_price,
    :allow_destroy => true

  after_create :copy_master_volume_prices

  def volume_prices_source
    if !is_master && product.variants_use_master_discount
      product.master
    else
      self
    end
  end

  def uses_volume_pricing?
    volume_prices_source.volume_prices.present?
  end

  def uses_master_discount?
    product.variants_use_master_discount
  end

  def requires_per_product_discount?
    uses_master_discount? && product.variants.present?
  end

  def total_volume_cost starting_quantity, quantity
    if progressive_volume_discount
      progressive_total_cost starting_quantity, quantity
    else
      uniform_total_cost starting_quantity, quantity
    end
  end

  def blank_volume_price attributes
    attributes['starting_quantity'].blank? && attributes['price'].blank?
  end

  private
  def copy_master_volume_prices
    return if self.is_master?
    self.progressive_volume_discount = self.product.master.progressive_volume_discount
    self.volume_prices = self.product.master.volume_prices.map do |vp|
      VolumePrice.new vp.attributes.slice('starting_quantity', 'price')
    end
  end

  def uniform_total_cost starting_quantity, quantity
    total_quantity = quantity + starting_quantity
    final_price = default_price = self.price

    volume_prices.each do |vp|
      break if vp.starting_quantity > total_quantity
      final_price = vp.price
    end

    quantity * final_price
  end

  def progressive_total_cost units_processed, quantity
    total_cost = 0
    total_quantity = quantity + units_processed
    current_price = default_price = self.price

    volume_prices.each do |vp|
      if vp.starting_quantity - 1 > units_processed
        last_unit_for_this_price = [total_quantity, vp.starting_quantity - 1].min
        items_count = last_unit_for_this_price - units_processed
        total_cost += items_count * current_price
        units_processed = last_unit_for_this_price
      end
      break if vp.starting_quantity > total_quantity
      current_price = vp.price
    end

    if total_quantity > units_processed
      items_count = total_quantity - units_processed
      total_cost += items_count * current_price
    end

    total_cost
  end
end unless Variant.instance_methods.include? :volume_prices_source
