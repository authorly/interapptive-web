require 'open3'

class AndroidStorybookApplication < AbstractStorybookApplication
  CRUCIBLE_ANDROID_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/android/')
  CRUCIBLE_ANDROID_RES_DIR = File.join(CRUCIBLE_ANDROID_DIR, 'res')
  ANDROID_ICON_DIRECTORIES = {
    :app_icon_32_32 => 'drawable-ldpi',
    :app_icon_48_48 => 'drawable-mdpi',
    :app_icon_72_72 => 'drawable-hdpi',
    :app_icon_96_96 => 'drawable-xhdpi'
  }

  def compile
    download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    download_icons
    logger.info "Going to compile application with json:\n\n"
    logger.info @json_hash.inspect
    write_json_file
    #move_unused_files_out_of_compilation
    build_application
    #move_unused_files_to_resources
    move_default_icons_to_android_res
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

  def move_default_icons_to_android_res
    if @storybook.icon.present?
      move_default_icons(CRUCIBLE_TMP_RESOURCES_DIR, CRUCIBLE_ANDROID_RES_DIR)
    end
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

  def save_icon_files
    ANDROID_ICON_DIRECTORIES.each do |accessor, name|
      File.open(File.join(CRUCIBLE_ANDROID_RES_DIR, name, 'icon.png'), 'wb+') do |icon|
        open(@storybook.icon.app_icon.send(accessor).url, 'rb') do |read_file|
          icon << read_file.read
        end
      end
    end
  end

  def move_default_icons_to_tmp
    move_default_icons(CRUCIBLE_ANDROID_RES_DIR, CRUCIBLE_TMP_RESOURCES_DIR)
  end

  def move_default_icons(from_dir, to_dir)
    ANDROID_ICON_DIRECTORIES.values.each do |name|
      FileUtils.mv(File.join(from_dir, name, 'icon.png'), File.join(to_dir, name))
    end
  end
end
