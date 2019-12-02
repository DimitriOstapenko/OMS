class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable, :timeoutable

  enum role: ROLES

  validates :name, :email,  presence: true, length: { maximum: 50 }
  validates :password, length: {minimum: 6}, allow_blank: true
  validates :client_id, presence: true, if: Proc.new { |u| u.client? } 
  
  after_initialize :set_default_role, :if => :new_record?
  before_save :set_client, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  def client_name
    Client.find(self.client_id).name if self.client_id 
  end

  def set_client
    client = Client.find_by(contact_email: self.email)
    if client.present?
      self.client_id = client.id 
      self.role = :client
    end
  end

end
