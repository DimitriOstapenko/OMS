class PackingList < ApplicationRecord
  belongs_to :user
  has_many :placements
        
  mount_uploader :csv, PlistCsvUploader
#  after_initialize :set_totals
  validate :validate_csv_file, on: :create 
  
  default_scope -> { order(status: :asc, created_at: :desc) }
  
  def csv_file_present?
    File.exists?(self.csv_path)
  end

  def csv_path
    PLISTS_PATH.join(self.filename) rescue nil
  end

  def filespec
    csv_path
  end

  def status_str
    PLIST_STATUSES.invert[self.status].to_s rescue nil
  end

# Return array of lines from CSV   
  def contents
    self.csv.read.split("\r\n")
  end 

  def filename
    self.name + '.csv'
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

    (errors.add(:packing_list, "No CSV name"); return) unless self.name.present?

    csv_text = File.read( self.csv_path ) rescue nil
    (errors.add(:packing_list, "Could not read CSV file #{self.csv_path}"); return) unless csv_text

    md5 = Digest::MD5.file(self.csv_path).to_s rescue nil
    pl = PackingList.find_by(md5: md5) if md5
    (errors.add(:packing_list, "This packing list was already uploaded (#{pl.name})"); return) if pl

    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1') rescue nil
    (errors.add(:packing_list, "CSV file format error"); return) unless csv

    return unless csv.first[2].to_i > 0  # pcs column must be integer
    ttl_pcs = lines = pending_active_pcs = 0; products = {}; orders = {};
    csv.each do |row|
      lines +=1
      order_id = row[0].to_i
      (errors.add(:orders, "line #{lines}: bad order number"); return) if order_id == 0
      order = Order.find(order_id) rescue nil
      (errors.add(:orders, "line #{lines}: order '#{row[0]}' does not exist"); return) unless order.present?
      ref_code = row[1].strip.gsub('"','')
      product = Product.find_by(ref_code: ref_code)
      (errors.add(:products, "line #{lines}: unknown product code #{ref_code}"); return) unless product
      placement = Placement.find_by(order_id: order_id, product_id: product.id)
      (errors.add(:pcs, "line #{lines}: Placement for order #{order.id}  product #{ref_code} does not exist"); return) unless placement.present?
      pcs = row[2].to_i
      (errors.add(:pcs, "line #{lines}: bad number of pieces: '#{row[2]}'"); return) if pcs == 0
      if product.present?
        pending_active_pcs = order.pending(product.id)
        (errors.add(:pcs, "line #{lines}: wrong number of pcs (#{pcs}) to ship for order #{order.id}/#{product.ref_code}: we only have #{pending_active_pcs} pending/active pcs  "); return) if pending_active_pcs < pcs
      end
      self.placements.push(placement)
      placement.update_attributes(to_ship: pcs )
      orders[order_id] = 1 if order_id    
      products[ref_code] = 1 if ref_code  
      ttl_pcs += pcs 
    end

    return if errors.any?
    self.md5 = md5
    self.lines = lines 
    self.orders = orders.keys.count
    self.products = products.keys.count
    self.pcs = ttl_pcs
 end

end
