class Price < ApplicationRecord
  
  default_scope -> { order(scale: :asc, category: :asc) }

  def category_str
    CATEGORIES.invert[self.category] rescue nil
  end

end
