class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Plantel <no-responder@plantel.cl>")
  layout "mailer"
end
