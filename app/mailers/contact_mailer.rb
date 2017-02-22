class ContactMailer < ActionMailer::Base
  def contact_mail(contact)
    @contact = contact
    mail(to: Rails.application.secrets.default_contact_mailer, subject: @contact.subject,
         from: "#{@contact.name} <#{@contact.email}>")
  end
end
