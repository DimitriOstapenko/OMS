# ______DO NOT COMMIT THIS FILE_____
# App constants 
#
# Magic comment - do not remove
# frozen_string_literal: true

# Get EUR/USD exchange rate  
def get_usd_fx
  require 'net/http'
  require 'json'

  uri = URI("https://api.exchangerate-api.com/v4/latest/USD")
  response = Net::HTTP.get(uri) rescue nil
  if response 
    response_obj = JSON.parse(response)
    return response_obj
  else
    return 1
  end
end

# General
DEBUG_FLAG = Rails.env.development?true:false
if Rails.env.production?
  SEND_EMAILS = `hostname`.match?('tiny') if Rails.env.production?
else 
  SEND_EMAILS = true           # User and staff email notifications
end

LOW_QUANTITY_THRESHOLD = 300  # Notify Staff if product inventory is < -100 

PROJECT_NAME = 'APD Order Management System'
PROJECT_SHORT_NAME = 'APD OMS'
PROJECT_URL = 'https://apdoms.com'
PROJECT_CONTACT_EMAIL = 'dosta@me.com'
PROJECT_CONTACT_PHONE = '0699436691'
IMAGE_BASE = Rails.root.join('public/images') # full path; put / in front to make relative
WillPaginate.per_page = 25

APD_CONTACT = 
"<b>ASIA PREMIER DEVELOPMENT LTD</b>

Room 1616, 16/F., Lippo Centre, Tower 2, 89 Queensway, 			
Admiralty, Hong Kong			
Susanna -  email: susanna@ecdbv.com"

USD_ACCOUNT = '447-0-817018-0'
EU_ACCOUNT  = '447-0-817019-9'

ECD_CONTACT = 
"<b>EUROPEAN COLLECTIBLE DISTRIBUTION B.V.</b>

PRINSES BEATRIXSTRAAT 7 - 5953LL REUVER - NETHERLANDS VAT NR. NL857575764B01"

# Users & Roles
ROLES = [:user, :staff, :admin, :production, :client, :su ]
USER_ROLE = 0
STAFF_ROLE = 1
ADMIN_ROLE = 2
PRODUCTION_ROLE = 3
CLIENT_ROLE = 4

# Product attributes
COLOURS = {'Black': 0, 'White': 1, 'Red': 2, 'Blue': 3, 'Green': 4, 'Yellow': 5, 'Silver': 6, 'Gray': 7, 'Brown': 8, 'Gold': 9, 'Purple': 10, 'Orange': 11}
CATEGORIES = {'Racing': 0, 'Street': 1, 'StreetLS': 2, 'Set': 3, 'Special Edition': 4}
BRANDS = {'Top Marques': 0, 'GP Replicas': 1, 'LS Collectibles': 2}

# Price types
PRICE_TYPES = {EU: 0, EU2: 1, USD: 2, EU3: 3, EU4: 4, EU5: 5, EU6: 6, USD2: 7, CNY: 8}
EU_PRICE = PRICE_TYPES[:EU]
EU2_PRICE = PRICE_TYPES[:EU2]
EU3_PRICE = PRICE_TYPES[:EU3]
EU4_PRICE = PRICE_TYPES[:EU4]
EU5_PRICE = PRICE_TYPES[:EU5]
EU6_PRICE = PRICE_TYPES[:EU6]
USD_PRICE = PRICE_TYPES[:USD]
USD2_PRICE = PRICE_TYPES[:USD2]
CNY_PRICE = PRICE_TYPES[:CNY]

CLIENT_TYPES = {Distributor: 0, Retailer: 1, Press: 2, Club: 3}
#SUPPLIERS = {'Bin': 1, 'Lin Zhang': 2, 'Ming': 3, 'Sam Qiu': 4, 'Xia': 5, 'Yang': 6 }

# Client Mailer
CLIENT_MAIL_CATEGORIES = {General: 0, Marketing: 1, 'New Products': 2, Promotion: 3}

# Mailer
REPLY_TO = '"apdoms.com" <ostapenko.dmitri@gmail.com>'  # Mail admin

ORDER_STATUSES  = { Pending: 0, Active: 1, Shipped: 2, Cancelled: 3 } 
PENDING_ORDER   = ORDER_STATUSES[:Pending]
ACTIVE_ORDER    = ORDER_STATUSES[:Active]
SHIPPED_ORDER   = ORDER_STATUSES[:Shipped]
CANCELLED_ORDER = ORDER_STATUSES[:Cancelled]

POS_PATH = Rails.root.join('pos')
INVOICES_PATH = Rails.root.join('invoices')
UPLOADS_PATH = Rails.root.join('public','uploads')

PAYMENT_METHODS = {'Bank Transfer Payment': 1, Paypal: 2}
PAYMENT_TERMS = {'In Advance by Wire Transfer': 1, 'Within 48 hours after receipt of goods': 2}

# phased out; now in shippers table:
#DELIVERY_BY = {'DHL': 1, 'Logfret': 2, 'UPS': 3}

# Reports
REPORTS_PATH = Rails.root.join('reports')

REPORT_TYPES = {Purchases: 'PUR', Sales: 'SAL'}
PURCHASES_REPORT = REPORT_TYPES[:Purchases]
SALES_REPORT = REPORT_TYPES[:Sales]

REPORT_CATEGORIES = {Client: 1, Product: 2, Summary: 3}
CLIENT_REPORT = REPORT_CATEGORIES[:Client]
PRODUCT_REPORT = REPORT_CATEGORIES[:Product]
SUMMARY_REPORT = REPORT_CATEGORIES[:Summary]

REPORT_TIMEFRAMES = {Day: 1, Week: 2, Month: 3, 'Quarter To Date': 4, Year: 5, 'Date Range': 6}
DAY_REPORT = REPORT_TIMEFRAMES[:Day]
WEEK_REPORT = REPORT_TIMEFRAMES[:Week]
MONTH_REPORT = REPORT_TIMEFRAMES[:Month]
QUARTER_REPORT = REPORT_TIMEFRAMES[:Quarter]
YEAR_REPORT = REPORT_TIMEFRAMES[:Year]
DRANGE_REPORT = REPORT_TIMEFRAMES[:'Date Range']

REPORT_DETAILS = {'Totals Only': 1, 'Itemized': 2}
TOTALS_ONLY_REPORT = REPORT_DETAILS[:'Totals Only']
ITEMIZED_REPORT = REPORT_DETAILS[:'Itemized']

PPOS_PATH = Rails.root.join('ppos')
PPO_STATUSES = {Active: 1, Archived: 2} 
ACTIVE_PPO = PPO_STATUSES[:Active]
ARCHIVED_PPO = PPO_STATUSES[:Archived]

PLISTS_PATH = Rails.root.join('plists')
PLIST_STATUSES = {Active: 0, Archived: 1 }
ACTIVE_PLIST = PLIST_STATUSES[:Active]
ARCHIVED_PLIST = PLIST_STATUSES[:Archived]

INVENTORIES_PATH = Rails.root.join('inventories')
INVENTORY_STATUSES = { Uploaded: 1, Processed: 2 }
UPLOADED_INVENTORY = INVENTORY_STATUSES[:Uploaded]
PROCESSED_INVENTORY = INVENTORY_STATUSES[:Processed]

GEO_AREAS = {World: 0, China: 1}
GEO_WRLD = GEO_AREAS[:World]
GEO_CN = GEO_AREAS[:China]

# Get exchange rates

fx = get_usd_fx 
USD_EUR_FX = fx['rates']['EUR'] rescue 1
USD_CNY_FX = fx['rates']['CNY'] rescue 1
EUR_CNY_FX = USD_CNY_FX / USD_EUR_FX rescue 1
