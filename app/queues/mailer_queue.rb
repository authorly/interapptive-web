class MailerQueue < GenericQueue
  @queue = :mailer

  # TODO: WA: This should be a generic mailer queue that
  # takes the actionmailer class, method that'd be used
  # for sending email and parameters for that method.
  # It should prepare a email message using those values
  # and send an email.
  def self.perform(to, index_url, ipa_url)
    UserMailer.compilation_completion_notification(to, index_url, ipa_url).deliver
  end
end
