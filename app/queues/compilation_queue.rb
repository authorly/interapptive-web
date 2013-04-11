require 'resque-loner'

class CompilationQueue < GenericQueue
  include Resque::Plugins::UniqueJob

  @queue = :compilation

  def self.perform(storybook_id, storybook_json)
    logger.info "Compiling storybook #{storybook_id} with #{storybook_json}"
    storybook = Storybook.find(storybook_id)
    storybook_application = StorybookApplication.new(storybook, storybook_json, 'interapptive')

    storybook_application.compile
    storybook_application.upload_compiled_application
    storybook_application.cleanup
    storybook_application.send_notification
    storybook_application
  end
end
