require 'open3'

class AndroidStorybookApplication < AbstractStorybookApplication
  CRUCIBLE_ANDROID_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/android/')

  def compile
    @json_hash = download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    logger.info "Going to compile application with json:\n\n"
    logger.info @json_hash.inspect
    write_json_file
    build_application
    @json_hash
  end

  def upload_compiled_application
    @storybook.android_application = File.open(File.join(CRUCIBLE_ANDROID_DIR, 'bin', 'ApplicationDemo-debug.apk'))
    logger.info "Uploading of apk file started for storybook #{@storybook.id}"
    @storybook.save!
    logger.info "Uploading of apk file completed for storybook #{@storybook.id}"
    true
  end

  def send_notification
    logger.info "Enqueuing notificatoin email for storybook #{@storybook.id}"
    Resque.enqueue(MailerQueue, 'UserMailer', 'android_compilation_completion_notification', @storybook.user.email, @storybook.android_application.url)
  end

  private

  def build_application
    Open3.popen3('./build_native.sh', :chdir => CRUCIBLE_ANDROID_DIR) do |i, o, e, t|
      logger.info o.read.chomp
    end
  end
end
