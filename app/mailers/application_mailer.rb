class ApplicationMailer < ActionMailer::Base
#  helper ApplicationHelper
  default from: REPLY_TO
  layout 'mailer'
end
