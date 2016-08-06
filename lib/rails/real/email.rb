require "rails/real/email/version"
require "rails/real/email/mail_check.rb"

module Rails
  module Real
    module Email
      def self.email_is_real?(email)
        MailCheck.run(email).invalid?
      end
    end
  end
end
