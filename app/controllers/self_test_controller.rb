class SelfTestController < ApplicationController

  before_action :logged_in_user, except: [:index]
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
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
    @empty_ctns = Product.where(ctns: nil)
    @empty_price_eu = Product.where(price_eu: nil)
    @empty_price_eu2 = Product.where(price_eu2: nil)
    @empty_price_usd = Product.where(price_usd: nil)

  end

end
