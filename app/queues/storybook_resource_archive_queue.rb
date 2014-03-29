require 'resque-loner'

class StorybookResourceArchiveQueue < GenericQueue
  include Resque::Plugins::UniqueJob

  @queue = :storybook_archive

  def self.perform(storybook_id, storybook_json, recipient_email)
    logger.info "Archving resources of storybook #{storybook_id}"
    storybook = Storybook.find(storybook_id)
    resource_downloader = StorybookResourceDownloader.new(storybook, storybook_json)

    resource_downloader.download_resources
    resource_downloader.archive
    resource_downloader.upload_resource_archive
    resource_downloader.send_notification(recipient_email)
    resource_downloader.cleanup
    resource_downloader
  end
end
