class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false, index: true
      t.decimal :price, precision: 10, scale: 2, null: false
      t.jsonb :metadata, default: {}
      t.references :category, null: false, foreign_key: true
      t.boolean :status, null: false, default: true
      t.timestamps
    end

    add_index :products, [:name, :price]
  end
end
