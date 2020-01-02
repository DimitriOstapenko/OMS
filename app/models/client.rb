class Client < ApplicationRecord

  has_many :products #, dependent: :destroy # remove when seeding products!
  has_many :orders #, dependent: :destroy   # remove when seeding clients
  has_one :user

  validates :name, :country, :cltype, :price_type, :contact_email, presence: true

  before_validation { name.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { contact_fname.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { contact_lname.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { contact_email.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { address.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { contact_phone.gsub!(/\D/,'')  rescue '' }

  before_save :set_client_code, :if => :new_record?

  default_scope -> { order(name: :asc, country: :asc) }
  
  scope :filter_by_name_or_country, lambda { |keyword|
    where("lower(name) LIKE '%#{keyword.downcase}%' OR lower(country) LIKE '%#{keyword.downcase}%'")
  }

  def client_type
    CLIENT_TYPES.invert[self.cltype] rescue nil
  end

  def price_type_str
    PRICE_TYPES.invert[self.price_type].to_s rescue nil
  end
  
# Client price depends on location, defined by price_type  
  def price(product)
      case self.price_type
        when EU_PRICE 
          product.price_eu
        when EU2_PRICE
          product.price_eu2
        when USD_PRICE
          product.price_usd
        else
          errors.add('*',"Client price_type is invalid")
          return false
      end 
  end

# locale to be used in currency conversions and total calculations  
  def locale
    country = Country[self.country]
    locale = (country.continent == 'Europe')?:fr:'us'.to_sym
  end

  def fx_rate
    (self.locale == :us)? USD_EUR_FX : 1
  end

  def contact_fullname
    (self.contact_lname.present?)?"#{self.contact_lname}, #{self.contact_fname}":self.contact_fname
  end

  def country_str
    Country[self.country].name rescue ''
  end

# Global method; search by keyword, price below, price above and recently added
  def self.search(params = {})
    clients = Client.all
    clients = clients.filter_by_name_or_country(params[:findstr]) if params[:findstr]
    clients
  end

# Generate unique client code
  def set_client_code
    c = self.name.upcase.strip.gsub(/\W/,'')[0..3] rescue ''
    id = self.id || Client.maximum(:id).next
    self.code = c + id.to_s
  end

  def registered_str
    self.user.present? ? 'Yes' : 'No'
  end

end
