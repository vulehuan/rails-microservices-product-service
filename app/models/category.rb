class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: [true, false] }
end
