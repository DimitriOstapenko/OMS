class Inventory < ApplicationRecord

  belongs_to :user

  mount_uploader :csv, InventoryCsvUploader
  validate :validate_csv_file, on: :create

  default_scope -> { order(status: :asc, created_at: :desc) }

  def csv_file_present?
    File.exists?(self.csv_path)
  end

  def csv_path
    INVENTORIES_PATH.join(self.filename) rescue nil
  end

  def filespec
    csv_path
  end

  def exists?
    File.exists?(self.filespec) rescue false
  end

  def status_str
    INVENTORY_STATUSES.invert[self.status].to_s rescue nil
  end

# Return array of lines from CSV
  def contents
    self.csv.read.split("\r\n")
  end

  def filename
    self.csv.identifier
  end

  def uploaded?
    self.status == UPLOADED_INVENTORY
  end

  def processed?
    self.status == PROCESSED_INVENTORY
  end

# Calculate total number of lines, products, pieces in this inventory file  N.B! Header line: "Ref_code", "Pcs"
# Verify CSV file syntax and validity of data
# set attributes: pcs, products, lines, md5

  def validate_csv_file
    require 'csv'
    require 'digest'

    (errors.add(:inventory, "No CSV name"); return) unless self.name.present?

    csv_text = File.read( self.csv_path ) rescue nil
    (errors.add(:inventory, "Could not read CSV file #{self.csv_path}"); return) unless csv_text

    md5 = Digest::MD5.file(self.csv_path).to_s rescue nil
    inv = Inventory.find_by(md5: md5) if md5
    (errors.add(:inventory, "This inventory file was already uploaded and processed (#{inv.name})"); return) if inv

    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1') rescue nil
    (errors.add(:inventory, "CSV file format error"); return) unless csv
    ttl_pcs = lines = 0; products = {};
    csv.each do |row|
      lines +=1
      next if row[1].blank? 
      pcs = row[1].to_i
      (errors.add(:pcs, "line #{lines}: bad number of pieces: '#{row[1]}'"); return) unless pcs.to_i == pcs # integer test
      ref_code = row[0].strip rescue nil
      (errors.add(:products, "line #{lines}: missing product code"); return) unless ref_code.present?
      product = Product.find_by(ref_code: ref_code)
      (errors.add(:products, "line #{lines}: unknown product code #{ref_code}"); return) unless product.present?
      products[ref_code] = 1 if ref_code
      ttl_pcs += pcs
      product.update_attribute(:stock, pcs) 
    end

    return if errors.any?
    self.md5 = md5
    self.lines = lines
    self.products = products.keys.count
    self.pcs = ttl_pcs
    self.status = PROCESSED_INVENTORY

  end



end
