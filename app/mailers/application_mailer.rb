class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.email_login
  layout 'mailer'

  def mail_to_admins(subject)
    recipients = User.where(:admin => true).map(&:email).uniq
    mail to: recipients, subject: subject unless recipients.empty?
  end
end
