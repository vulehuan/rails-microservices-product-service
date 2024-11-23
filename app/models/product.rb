class Product < ApplicationRecord
  belongs_to :category

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :metadata, presence: true
  validates :status, inclusion: { in: [true, false] }
end