# frozen_string_literal: true

class ProductCollectionSerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name, :price, :stock_quantity, :status
end
