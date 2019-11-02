class Client < ApplicationRecord

  has_many :products #, dependent: :destroy # remove when seeding products!
  has_many :orders #, dependent: :destroy   # remove when seeding clients
  has_one :user

  default_scope -> { order(name: :asc, country: :asc) }
  
  scope :filter_by_name_or_country, lambda { |keyword|
    where("lower(name) LIKE ?", "%#{keyword.downcase}%" ) &&
    where("lower(country) like ?", "%#{keyword.downcase}%")
  }


  def client_type
    CLIENT_TYPES.invert[self.cltype] rescue CLIENT_TYPES[0]
  end

  def contact_fullname
     "#{self.contact_lname}, #{self.contact_fname}" 
  end

  def cltype_str
    CLIENT_TYPES.invert[self.cltype]
  end

# Global method; search by keyword, price below, price above and recently added
  def self.search(params = {})
    clients = Client.all
    clients = clients.filter_by_name_or_country(params[:findstr]) if params[:findstr]
    clients
  end

end
