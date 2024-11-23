class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :weight, :status
end
