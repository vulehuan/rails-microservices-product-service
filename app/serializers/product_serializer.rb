class ProductSerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name, :price, :description, :stock_quantity, :metadata, :status
end
