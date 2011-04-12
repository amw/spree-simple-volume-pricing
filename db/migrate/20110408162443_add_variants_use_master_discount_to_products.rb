class AddVariantsUseMasterDiscountToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :variants_use_master_discount, :boolean,
      :null => false, :default => 0
  end

  def self.down
    remove_column :products, :variants_use_master_discount
  end
end
