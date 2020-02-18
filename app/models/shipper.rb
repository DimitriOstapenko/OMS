class Shipper < ApplicationRecord

  default_scope -> { order(name: :asc, email: :asc) }
  validates :name, presence: true, length: { maximum: 30 }, uniqueness: true
end
