class PackingList < ApplicationRecord
  belongs_to :user

  mount_uploader :csv, PlistCsvUploader
  after_initialize :set_totals
  
  def csv_file_present?
    File.exists?(self.csv_path)
  end

  def csv_path
    PLISTS_PATH.join(self.name) rescue nil
  end

  def status_str
    PLIST_STATUSES.invert[self.status].to_s rescue nil
  end

# Return array of lines from CSV   
  def contents
    self.csv.read.split("\r\n")
  end 

private 
# Calculate total number of lines & pieces in this plist  N.B! Header line: "Order", "Ref_code", "Pcs" 
# Verify CSV file syntax and validity of data
  def set_totals
    require 'csv'

    return unless self.name
    csv_text = File.read( PLISTS_PATH.join(self.name)) rescue nil
    return unless csv_text
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
    return unless csv

    return unless csv.first[2].to_i > 0  # pcs column must be integer
    ttl_pcs = lines = pending_active_pcs = 0; products = {}; orders = {};
    csv.each do |row|
      lines +=1
      order_id = row[0].to_i
      errors.add(:orders, "line #{lines}: bad order number") if order_id == 0

      order = Order.find(order_id) rescue nil
      errors.add(:orders, "line #{lines}: order does not exist") unless order.present?
      ref_code = row[1].strip
      product = Product.find_by(ref_code: ref_code)
      errors.add(:products, "line #{lines}: unknown product code #{ref_code}") unless product
      pcs = row[2].to_i
      errors.add(:pcs, "line #{lines}: bad number of pieces (#{row[2]})") if pcs == 0
      if product.present?
        pending_active_pcs = order.pending(product.id)
        errors.add(:pcs, "line #{lines}: insufficient number of active/pending pcs for this order: #{pending_active_pcs}") if pending_active_pcs < pcs
      end
      orders[order_id] = 1 if order_id    
      products[ref_code] = 1 if ref_code  
      ttl_pcs += pcs 
    end

    return unless errors.empty?
    self.lines = lines 
    self.orders = orders.keys.count
    self.products = products.keys.count
    self.pcs = ttl_pcs
 end

end
