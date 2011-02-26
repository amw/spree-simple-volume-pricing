class CreateVolumePrices < ActiveRecord::Migration
  def self.up
    create_table :volume_prices do |t|
      t.references :variant,        :null => false
      t.integer :starting_quantity, :null => false
      t.decimal :price,             :null => false, :precision => 8, :scale => 2

      t.timestamps
    end
    add_index :volume_prices, [:variant_id, :starting_quantity], :unique => true
    execute <<-SQL
      ALTER TABLE volume_prices
        ADD CONSTRAINT fk_volume_prices_variants
        FOREIGN KEY (variant_id)
        REFERENCES variants(id)
    SQL
  end

  def self.down
    drop_table :volume_prices
  end
end
