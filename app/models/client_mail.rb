class ClientMail < ApplicationRecord

  has_many :clients
  default_scope -> { order(ts_sent: :desc) }

end
