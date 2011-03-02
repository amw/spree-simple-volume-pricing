class AddVolumeDiscountToLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :volume_discount, :decimal,
                 :precision => 8, :scale => 2, :null => false, :default => 0
  end

  def self.down
    remove_column :line_items, :volume_discount
  end
end
