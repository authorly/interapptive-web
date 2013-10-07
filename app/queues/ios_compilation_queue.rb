require 'resque-loner'

class IosCompilationQueue < GenericQueue
  include Resque::Plugins::UniqueJob

  @queue = :ios_compilation

  def self.perform(storybook_id, storybook_json, recipient_email)
    logger.info "Compiling ios storybook #{storybook_id} with #{storybook_json}"
    storybook = Storybook.find(storybook_id)
    storybook_application = IosStorybookApplication.new(storybook, storybook_json, 'authorly')

    storybook_application.cleanup
    storybook_application.compile
    storybook_application.upload_compiled_application
    storybook_application.send_notification(recipient_email)
    storybook_application
  end
end
