class AddImageToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :image, :string
  end
end
