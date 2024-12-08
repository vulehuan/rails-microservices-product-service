# frozen_string_literal: true

class BaseProductSerializer < ActiveModel::Serializer
  attributes :id, :image, :category_id, :name, :price, :stock_quantity, :status

  def price
    object.price.to_f
  end
end
