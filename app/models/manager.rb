class Manager < ApplicationRecord
  
#   belongs_to :product, inverse_of: :managers

   default_scope -> { order(lname: :asc, fname: :asc) }

   validates :lname, presence: true, length: { maximum: 10 }, uniqueness: true
  
  def full_name
    self.lname + ', ' + self.fname
  end
end
