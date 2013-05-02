class MailerQueue < GenericQueue
  @queue = :mailer

  # OPTIMIZE: WA: Build a priority based queuing system for email
  # delivery.
  def self.perform(mailer_class, mailer_method, *args)
    logger.info "Sending #{mailer_class}.#{mailer_method} with #{args.inspect}"
    mailer_class.constantize.send(mailer_method, *args).deliver
  end
end
