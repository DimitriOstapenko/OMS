class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable #, :timeoutable
  
  enum role: ROLES
  has_many :orders

  validates :name, presence: true, length: { maximum: 50 }
#  validates :email, length: { maximum: 80 }, uniqueness: true
  validates :password, length: {minimum: 6}, allow_blank: true
#  validates :client_id, presence: true, if: Proc.new { |u| u.client? } 

  default_scope -> { order(Arel.sql("upper(name)"), email: :asc) }  # see also sort in controller

  scope :filter_by_name_or_email, lambda { |keyword|
    where("lower(name) LIKE '%#{keyword.downcase}%' OR lower(email) LIKE '%#{keyword.downcase}%'" )
  }
  
  after_initialize :set_default_role, :if => :new_record?
  before_create :set_client
  after_save :send_emails, :if => :new_record?

  def set_default_role
    self.role ||= :user
    self.client_id ||= nil
  end

# try to find client with this email; set role to client if found  
  def set_client
    client = Client.find_by(contact_email: self.email)
    if client.present?
      self.client_id = client.id 
      self.role = :client
    end
  end

# For cases where email is known and no confirmation link is required  
  def mark_as_confirmed
    self.confirmation_token = nil
    self.confirmed_at = Time.now
  end

  def active?
    self.confirmed_at.present?
  end 
    
  def client_name
    Client.find(self.client_id).name if self.client_id 
  end

# Was user invited to register by staff?  
  def invited?
    self.invited_by.present?
  end

# Notify staff, admins
  def send_emails
    UserMailer.new_registration(self).deliver unless self.invited?
  end

# Do not send confirmation email if created through invite
  def send_confirmation_notification?
    !self.invited?
  end

# Global method; search by name or email
  def self.search(keyword = '')
    User.filter_by_name_or_email(keyword) if keyword
  end

end
