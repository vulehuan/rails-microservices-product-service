class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false, index: { unique: true }
      t.decimal :weight, default: 0
      t.boolean :status, null: false, default: true
      t.timestamps
    end
  end
end
