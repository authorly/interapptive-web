begin
  require 'cfpropertylist'
rescue LoadError
end

class IosStorybookApplication < AbstractStorybookApplication
  CRUCIBLE_IOS_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/ios/')
  IOS_ICON_FILE_NAMES = {
    :app_icon_72_72   => 'Icon-72.png',
    :app_icon_144_144 => 'Icon-72@2x.png',
    :app_icon_20_20   => 'Icon-Small-20.png',
    :app_icon_40_40   => 'Icon-Small-20@2x.png',
    :app_icon_30_30   => 'Icon-Small-30.png',
    :app_icon_60_60   => 'Icon-Small-30@2x.png',
    :app_icon_50_50   => 'Icon-Small-50.png',
    :app_icon_100_100 => 'Icon-Small-50@2x.png',
    :app_icon_29_29   => 'Icon-Small.png',
    :app_icon_58_58   => 'Icon-Small@2x.png',
    :app_icon_57_57   => 'Icon.png',
    :app_icon_114_114 => 'Icon@2x.png'
  }

  def initialize(*args)
    super
    @deploy_to_url = "https://#{Rails.application.config.s3_bucket}.s3.amazonaws.com/compiled_applications/#{@storybook.id}"
  end

  def compile
    download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    download_icons
    logger.info "Going to compile application with json:\n\n"
    logger.info @json_hash.inspect
    write_json_file
    write_rake_file
    #move_unused_files_out_of_compilation
    begin
      xbuild_application
    ensure
      #move_unused_files_to_resources
      move_default_icons_to_resources
    end
    @json_hash
  end

  def upload_compiled_application
    @storybook.compiled_application = File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', @target + '.ipa'))
    logger.info 'Uploading of ipa file started!'
    @storybook.save!
    logger.info 'Uploading of ipa file completed!'

    self.class.fog_directory.files.new(
      :key          => "compiled_applications/#{@storybook.id}/manifest.plist",
      :content_type => 'text/xml',
      :public       => true,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'manifest.plist'))
    ).save
    logger.info 'Uploading of ipa file manifest.plist completed!'

    self.class.fog_directory.files.new(
      :key          => "compiled_applications/#{@storybook.id}/index.html",
      :content_type => 'text/html',
      :public       => true,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'index.html'))
    ).save
    logger.info 'Uploading of ipa file index.html completed!'
    true
  end

  def send_notification(recipient_email)
    Resque.enqueue(MailerQueue, 'UserMailer', 'ios_compilation_completion_notification', recipient_email, @storybook.compiled_application.index_html_url, @storybook.compiled_application.url)
  end

  def move_default_icons_to_resources
    if @storybook.icon.present?
      move_default_icons(CRUCIBLE_TMP_RESOURCES_DIR, CRUCIBLE_RESOURCES_DIR)
    end
  end

  private

  def save_icon_files
    IOS_ICON_FILE_NAMES.each do |accessor, name|
      File.open(File.join(CRUCIBLE_RESOURCES_DIR, name), 'wb+') do |icon|
        open(@storybook.icon.app_icon.send(accessor).url, 'rb') do |read_file|
          icon << read_file.read
        end
      end
    end
  end

  def move_default_icons_to_tmp
    move_default_icons(CRUCIBLE_RESOURCES_DIR, CRUCIBLE_TMP_RESOURCES_DIR)
  end

  def move_default_icons(from_dir, to_dir)
    IOS_ICON_FILE_NAMES.values.each do |name|
      FileUtils.mv(File.join(from_dir, name), to_dir)
    end
  end

  def xbuild_application
    f = IO.popen("cd #{CRUCIBLE_IOS_DIR} && security unlock-keychain -p '#{Rails.application.config.crucible_keychain_password}' /Users/Xcloud/Library/Keychains/login.keychain && bundle exec rake beta:deploy --trace")
    # TODO: WA: Following blocks the worker process till log is
    # written. Fork it to child process.
    logger.info f.readlines.join
    f.close
  end

  def write_rake_file
    task = <<-END
      require 'rubygems'
      require 'betabuilder'
      BetaBuilder::Tasks.new do |config|
        config.target = '#{@target}'
        config.configuration = 'Adhoc'
        config.app_name = '#{@target}'

        config.deploy_using(:web) do |web|
          web.deploy_to = '#{@deploy_to_url}'
          web.remote_host = 'fake_path'
          web.remote_directory = 'fake_directory'
        end
      end
    END

    File.open(File.join(CRUCIBLE_IOS_DIR, 'Rakefile'), 'w') do |f|
      f.write(task)
    end
  end
end
