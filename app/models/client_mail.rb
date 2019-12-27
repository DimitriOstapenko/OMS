class ClientMail < ApplicationRecord

  has_many :clients
  default_scope -> { order(updated_at: :desc) }

  validates :title, :category, :client_type, :body, presence: true
  
  before_validation :set_target_emails!

  def target_email_count
    self.target_emails.split(',').count rescue 0
  end

  def target_emails_array
    self.target_emails.split(',') rescue []
  end

  def set_target_emails!
    email_array = Client.where(cltype: self.client_type).pluck(:contact_email) rescue []
    if email_array.any?
       self.target_emails = email_array.join(',')
    else 
       errors.add('Warning:', 'No target emails were found matching given client category')
    end
  end

# return array of all staff emails  
  def staff_emails_array
    email_array = User.where(role: STAFF_ROLE).pluck(:email) rescue []
  end

end
