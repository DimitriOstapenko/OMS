class Client < ApplicationRecord

  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :user

  default_scope -> { order(name: :asc, country: :asc) }

  def client_type
    CLIENT_TYPES.invert[self.cltype] rescue CLIENT_TYPES[0]
  end

end
