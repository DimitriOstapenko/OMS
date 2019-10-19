class Product < ApplicationRecord


  def scale_str
    '1:'+scale.to_s
  end
end
