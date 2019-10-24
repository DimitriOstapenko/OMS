class Client < ApplicationRecord

  default_scope -> { order(name: :asc, country: :asc) }

  def client_type
    CLIENT_TYPES.invert[self.cltype] rescue CLIENT_TYPES[0]
  end
end
