require 'resque-loner'

class SubscriptionPublicationQueue < GenericQueue
  include Resque::Plugins::UniqueJob
  @queue = :subscription_publication

  def self.perform(storybook_id, storybook_json, recipient_email)
    logger.info "Publishing storybook #{storybook_id}"
    storybook              = Storybook.find(storybook_id)
    subscription_publisher = SubscriptionPublisher.new(storybook, storybook_json)

    subscription_publisher.publish
    subscription_publisher.send_notification(recipient_email)
    subscription_publisher
  end
end
