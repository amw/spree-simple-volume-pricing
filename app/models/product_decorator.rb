Product.class_eval do
  delegate_belongs_to :master,
    :volume_prices_attributes=,
    :progressive_volume_discount

  def save_master
    return unless master && (master.changed? || master.new_record? || master.changed_for_autosave?)
    raise ActiveRecord::Rollback unless master.save
  end

  private
  def duplicate_extra original
    return unless original
    self.master.volume_prices = original.master.volume_prices.map do |vp|
      VolumePrice.new vp.attributes.slice('starting_quantity', 'price')
    end
  end
end
