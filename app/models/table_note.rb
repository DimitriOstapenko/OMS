class TableNote < ApplicationRecord
  default_scope -> { order(table_name: :asc) }
  
  validates :table_name,  presence: true, length: { maximum: 1024 }
end
