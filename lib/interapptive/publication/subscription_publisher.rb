class SubscriptionPublisher
  def initialize(storybook, storybook_json)
    @json                = storybook_json
    @storybook           = storybook
    @resource_downloader = StorybookResourceDownloader.new(storybook, storybook_json)
  end

  def publish
    archive_resources
    @storybook.subscription_publish_request.update_attribute(:status, SubscriptionPublishRequest::STATUSES[:published])
    cleanup
  end

  def archive_resources
    @resource_downloader.download_resources
    @resource_downloader.archive
    upload_resource_archive
  end

  def cleanup
    @resource_downloader.cleanup
  end

  def upload_resource_archive
    subscription_storybook = @storybook.subscription_storybook || @storybook.build_subscription_storybook

    subscription_storybook.storybook_json = ActiveSupport::JSON.decode(@json)
    subscription_storybook.assets = File.open(@resource_downloader.zip_file_path)
    subscription_storybook.save
  end

  def send_notification(recipient_email)
    Resque.enqueue(MailerQueue, 'AdminMailer', 'storybook_publication_completion_notification', recipient_email, @storybook.id)
    Resque.enqueue(MailerQueue, 'UserMailer', 'storybook_publication_completion_notification', @storybook.id)
    KMTS.record(recipient_email, "Application published")
  end
end
