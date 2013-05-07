require 'resque-loner'

class AndroidCompilationQueue < GenericQueue
  include Resque::Plugins::UniqueJob

  @queue = :android_compilation

  def self.perform(storybook_id, storybook_json)
    logger.info "Compiling android storybook #{storybook_id} with #{storybook_json}"
    storybook = Storybook.find(storybook_id)
    storybook_application = AndroidStorybookApplication.new(storybook, storybook_json, 'testing')

    storybook_application.compile
    storybook_application.upload_compiled_application
    storybook_application.cleanup
    storybook_application.send_notification
    storybook_application
  end
end
