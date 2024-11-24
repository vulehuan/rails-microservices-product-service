class ProductSerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name, :image, :price, :description, :stock_quantity, :metadata, :status
end
