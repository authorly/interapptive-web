require 'spec_helper'

describe SubscriptionPublisher do
  let(:storybook) { Factory :storybook, cover_image: Factory(:image) }
  let(:storybook_json) { '{}'}
  let(:subscription_publisher) { SubscriptionPublisher.new(storybook, storybook_json)}

  before(:each) do
    storybook.create_or_update_subscription_publish_request
  end

  describe '#publish' do
    before do
      Factory(:subscription_storybook, storybook: storybook)
    end

    it 'archives and cleans up' do
      subscription_publisher.should_receive(:archive_resources).and_return(true)
      subscription_publisher.should_receive(:cleanup).and_return(true)
      subscription_publisher.publish
      expect(storybook.subscription_publish_request.status).to eql(SubscriptionPublishRequest::STATUSES[:published])
    end
  end

  describe '#archive_resources' do
    it 'archives and uploads' do
      rd = subscription_publisher.instance_variable_get(:@resource_downloader)
      rd.should_receive(:download_resources).and_return(true)
      rd.should_receive(:archive).and_return(true)
      subscription_publisher.should_receive(:upload_resource_archive).and_return(true)
      subscription_publisher.archive_resources
    end
  end

  describe '#cleanup' do
    it 'cleans up' do
      rd = subscription_publisher.instance_variable_get(:@resource_downloader)
      rd.should_receive(:cleanup).and_return(true)
      subscription_publisher.cleanup
    end
  end

  describe '#upload_resource_archive' do
    it 'uploads the resources' do
      rd = subscription_publisher.instance_variable_get(:@resource_downloader)
      rd.should_receive(:zip_file_path).and_return(File.join(Rails.root, 'spec', 'factories', 'ResourcesCrucible', 'storybook.zip'))
      expect(storybook.subscription_storybook).to be_blank
      subscription_publisher.upload_resource_archive
      expect(storybook.subscription_storybook).to be_present
    end
  end

  describe '#send_notification' do
    it 'enqueues proper notifications' do
      Resque.should_receive(:enqueue).with(MailerQueue, 'AdminMailer', 'storybook_publication_completion_notification', 'foo@bar.com', storybook.id)
      Resque.should_receive(:enqueue).with(MailerQueue, 'UserMailer', 'storybook_publication_completion_notification', storybook.id)
      KMTS.should_receive(:record).with('foo@bar.com', 'Application published')
      subscription_publisher.send_notification('foo@bar.com')
    end
  end
end
