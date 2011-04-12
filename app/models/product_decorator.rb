Product.class_eval do
  delegate_belongs_to :master,
    :volume_prices_attributes=,
    :progressive_volume_discount

  def uses_volume_pricing?
    if variants_use_master_discount
      !master.volume_prices.empty?
    else
      !Product.where(:id => id).joins(:variants => :volume_prices).empty?
    end
  end

  def save_master
    return unless master && (master.changed? || master.new_record? || master.changed_for_autosave?)
    raise ActiveRecord::Rollback unless master.save
  end

  def all_variant_ids
    @all_variant_ids ||= Variant.where(:product_id => id).map &:id
  end

  private
  def duplicate_extra original
    return unless original
    self.master.volume_prices = original.master.volume_prices.map do |vp|
      VolumePrice.new vp.attributes.slice('starting_quantity', 'price')
    end
  end
end unless Product.instance_methods.include? :all_variant_ids
