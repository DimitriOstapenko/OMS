class SelfTestController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update, :index ]
  before_action :admin_user, only: [:destroy]

  def index
    @empty_names = Client.where('length(name)<2')
    @empty_addresses = Client.where(address: nil)
    @empty_countries = Client.where(country: nil)
    @empty_emails = Client.where(contact_email: nil)

    @empty_refcodes = Product.where('length(ref_code)<2')
    @empty_descr = Product.where('length(description)<2')
    @empty_scales = Product.where(scale: nil)
    @empty_colours = Product.where(colour: nil)
    @empty_brands = Product.where(brand: nil)
    @empty_categories = Product.where(category: nil)
    @empty_weights = Product.where(weight: nil)
    @empty_ctns = Product.where(ctns: nil)
    @empty_price_eu = Product.where(price_eu: nil)
    @empty_price_eu2 = Product.where(price_eu2: 0)
    @empty_price_eu3 = Product.where(price_eu3: 0)
    @empty_price_eu4 = Product.where(price_eu4: 0)
    @empty_price_eu5 = Product.where(price_eu5: 0)
    @empty_price_usd = Product.where(price_usd: nil)
    @empty_price_usd2 = Product.where(price_usd2: 0)
    @empty_price_cny = Product.where(price_cny: 0)

    @missing_images = []
    Product.all.each do |p|
      next if p.image_file_present?
      @missing_images.push(p) 
    end

    @images = Pathname.glob("#{IMAGE_BASE}/[TLG]*.jpg")
    @missing_ref_codes = []
    @images.each do |path|
      ref_code = path.basename('.jpg').to_s
      next if Product.exists?(ref_code: ref_code)
      @missing_ref_codes.push(ref_code) 
    end

    @missing_price_rules = []
    BRANDS.values.each do |brand|
      CATEGORIES.values.each do |category|
        SCALES.values.each do |scale|
          @missing_price_rules.push(Price.new(scale:scale,category:category,brand:brand)) unless Price.exists?(scale:scale, category:category, brand:brand)   
        end
      end
    end

    @products_without_matching_price_rule = []
    Product.all.each do |prod|
      @products_without_matching_price_rule.push(prod) unless Price.exists?(scale:prod.scale, category:prod.category, brand:prod.brand)
    end


  end

end
