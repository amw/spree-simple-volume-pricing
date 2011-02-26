Product.class_eval do
  delegate_belongs_to :master, :volume_prices_attributes=

  def save_master
    return unless master && (master.changed? || master.new_record? || master.changed_for_autosave?)
    raise ActiveRecord::Rollback unless master.save
  end
end
