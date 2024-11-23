class AddStockQuantityAndLockVersionToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :stock_quantity, :integer, default: 0
    add_column :products, :lock_version, :integer, default: 0
  end
end
