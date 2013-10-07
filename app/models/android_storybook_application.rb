require 'open3'

class AndroidStorybookApplication < AbstractStorybookApplication
  CRUCIBLE_ANDROID_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/android/')

  def compile
    download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    logger.info "Going to compile application with json:\n\n"
    logger.info @json_hash.inspect
    write_json_file
    #move_unused_files_out_of_compilation
    build_application
    #move_unused_files_to_resources
    @json_hash
  end

  def upload_compiled_application
    @storybook.android_application = File.open(File.join(CRUCIBLE_ANDROID_DIR, 'bin', 'ApplicationDemo-debug.apk'))
    logger.info "Uploading of apk file started for storybook #{@storybook.id}"
    @storybook.save!
    logger.info "Uploading of apk file completed for storybook #{@storybook.id}"
    true
  end

  def send_notification(recipient_email)
    logger.info "Enqueuing notificatoin email for storybook #{@storybook.id}"
    Resque.enqueue(MailerQueue, 'UserMailer', 'android_compilation_completion_notification', recipient_email, @storybook.android_application.url)
  end

  private

  def build_application
    logger.info("Going to build android application for storybook: #{@storybook.id}")
    Open3.popen3('./build_native.sh', :chdir => CRUCIBLE_ANDROID_DIR) do |i, o, e, t|
      logger.info o.read.chomp
      logger.info e.read.chomp
    end
    logger.info("Done building android application for storybook: #{@storybook.id}")
  end
end
