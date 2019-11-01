class Client < ApplicationRecord

  has_many :products #, dependent: :destroy # remove when seeding clients!
  has_many :orders #, dependent: :destroy   # remove when seeding clients
  has_one :user

  default_scope -> { order(name: :asc, country: :asc) }

  def client_type
    CLIENT_TYPES.invert[self.cltype] rescue CLIENT_TYPES[0]
  end

  def contact_fullname
     "#{self.contact_lname}, #{self.contact_fname}" 
  end

  def cltype_str
    CLIENT_TYPES.invert[self.cltype]
  end

end
