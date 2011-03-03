class AddProgressiveVolumeDiscountToVariants < ActiveRecord::Migration
  def self.up
    add_column :variants, :progressive_volume_discount, :boolean,
                 :null => false, :default => 0
  end

  def self.down
    remove_column :variants, :progressive_volume_discount
  end
end
