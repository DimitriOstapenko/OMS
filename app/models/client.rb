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
        when EU3_PRICE
          product.price_eu3
        when EU4_PRICE
          product.price_eu4
        when EU5_PRICE
          product.price_eu5
        when EU6_PRICE
          product.price_eu6
        when USD_PRICE
          product.price_usd
        when USD2_PRICE
          product.price_usd2
        else
          errors.add('Price Type Error',"Client price_type is invalid")
          return 0
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

  def pref_delivery_by_str 
    DELIVERY_BY.invert[self.pref_delivery_by].to_s rescue nil
  end

# Global method; search by name, price_type, country 
  def self.search(keyword = '')
    case keyword
       when /^(usd|eu)([[:digit:]]?)$/i       # Search by price type
         keyword = $1 if $2 == '1'
         ptype = PRICE_TYPES[keyword.upcase.to_sym] rescue nil
         clients = Client.where("price_type =?", ptype) 
       when /^[[:graph:]]+/        # Searh by country or name   
         clients = Client.filter_by_name_or_country(keyword)
       else
         clients = []
     end

    return clients
  end

# Generate unique client code
  def set_client_code
    c = self.name.upcase.strip.gsub(/\W/,'')[0..3] rescue ''
    id = self.id || Client.maximum(:id).next
    self.code = c + id.to_s
  end

# Is client registered in OMS?  
  def registered_str
    self.user.present? ? 'Yes' : 'No'
  end

end
