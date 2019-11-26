class Supplier < ApplicationRecord

  default_scope -> { order(lname: :asc, fname: :asc) }

#  validates :lname, presence: true, length: { maximum: 10 }, uniqueness: true

  def full_name
    self.lname? ? self.lname + ', ' + self.fname : self.fname
  end
end
