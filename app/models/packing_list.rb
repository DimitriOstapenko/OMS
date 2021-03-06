class PackingList < ApplicationRecord
  belongs_to :user
  has_many :placements
        
  mount_uploader :csv, PlistCsvUploader
  validate :validate_csv_file, on: :create 
  
  default_scope -> { order(status: :asc, created_at: :desc) }
  
  def csv_file_present?
    File.exists?(self.csv_path)
  end

  def csv_path
    PLISTS_PATH.join(self.filename) rescue nil
#   self.csv.to_s
  end

  def filespec
    csv_path
  end

  def exists?
    File.exists?(self.filespec) rescue false
  end

  def status_str
    PLIST_STATUSES.invert[self.status].to_s rescue nil
  end

# Return array of lines from CSV   
  def contents
    self.csv.read.split("\r\n") rescue nil
  end 

  def filename
    self.csv.identifier
  end

  def active?
    self.status == ACTIVE_PLIST
  end

  def archived?
    self.status == ARCHIVED_PLIST
  end

  def self.any_active?
    self.exists?(status: ACTIVE_PLIST)
  end

private 

# Calculate total number of lines & pieces in this plist  N.B! Header line: "Order", "Ref_code", "Pcs" 
# Verify CSV file syntax and validity of data
# Add placements and set "to_ship" quantity

  def validate_csv_file
    require 'csv'
    require 'digest'

    (errors.add(:packing_list, ": No CSV name"); return) unless self.name.present?
    csv_text = File.read( self.csv_path ) 
    (errors.add(:packing_list, ": Could not read CSV file #{self.csv_path}"); return) unless csv_text

    md5 = Digest::MD5.file(self.csv_path).to_s rescue nil
    pl = PackingList.find_by(md5: md5) if md5
    (errors.add(:file_exists, ": This packing list was already uploaded (#{pl.name})"); return) if pl

    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
    (errors.add(:file_format, "CSV file format error"); return) unless csv

    (errors.add(:file_format_error, "This is not Comma-Separated Vaue file (#{csv.first[0]}). Fix it and try again"); return) unless csv.first[2].to_i > 0  # pcs column must be integer
    ttl_pcs = lines = pending_active_pcs = 0; products = {}; orders = {};
    csv.each do |row|
      lines +=1
      order_id = row[0].to_i
      (errors.add(:orders, "- line #{lines}: bad order number"); return) if order_id == 0
      order = Order.find(order_id) rescue nil
      (errors.add(:missing_order, "- line #{lines}: order '#{row[0]}' does not exist"); return) unless order.present?
      ref_code = row[1].strip.gsub('"','')
      (errors.add(:products, "line #{lines}: missing product code"); return) unless ref_code.present?
      product = Product.find_by(ref_code: ref_code)
      (errors.add(:products, "- line #{lines}: unknown product code #{ref_code}"); return) unless product
      placement = Placement.find_by(order_id: order_id, product_id: product.id)
      (errors.add(:missing_placement, "- line #{lines}: Placement for order #{order.id}  product #{ref_code} does not exist"); return) unless placement.present?
      pcs = row[2].to_i
      (errors.add(:pcs, "- line #{lines}: bad number of pieces: '#{row[2]}'"); return) if pcs == 0
      pending_active_pcs = order.pending(product.id)
      (errors.add(:wrong_pending_pcs, "- line #{lines}: wrong number of pcs (#{pcs}) to ship for order #{order.id}/#{product.ref_code}: we have #{pending_active_pcs} pending/active pcs  "); return) if pending_active_pcs < pcs
      (errors.add(:insufficient_pcs, "- line #{lines}: insufficient inventory for order #{order.id}/#{product.ref_code}: #{pcs} pcs marked for shipment, we only have #{product.stock} pcs in stock  "); return) if pcs > product.stock
      self.placements.push(placement)
      placement.update_attribute(:to_ship, pcs )
      orders[order_id] = 1 if order_id    
      products[ref_code] = 1 if ref_code  
      ttl_pcs += pcs 
    end
    (errors.add(:no_pcs, "Nothing to ship. Check your file"); return) if ttl_pcs < 1

    return if errors.any?
    self.md5 = md5
    self.lines = lines 
    self.orders = orders.keys.count
    self.products = products.keys.count
    self.pcs = ttl_pcs
 end

end
