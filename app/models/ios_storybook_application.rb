begin
  require 'cfpropertylist'
rescue LoadError
end

class IosStorybookApplication < AbstractStorybookApplication
  CRUCIBLE_IOS_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/ios/')

  def initialize(*args)
    super
    @deploy_to_url = "https://interapptive.s3.amazonaws.com/compiled_applications/#{@storybook.id}"
  end

  def compile
    @json_hash = download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    logger.info "Going to compile application with json:\n\n"
    logger.info @json_hash.inspect
    write_json_file
    write_rake_file
    xbuild_application
    @json_hash
  end

  def upload_compiled_application
    @storybook.compiled_application = File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', @target + '.ipa'))
    logger.info 'Uploading of ipa file started!'
    @storybook.save!
    logger.info 'Uploading of ipa file completed!'

    FOG_DIRECTORY.files.new(
      :key          => "compiled_applications/#{@storybook.id}/manifest.plist",
      :content_type => 'text/xml',
      :public       => true,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'manifest.plist'))
    ).save
    logger.info 'Uploading of ipa file manifest.plist completed!'

    FOG_DIRECTORY.files.new(
      :key          => "compiled_applications/#{@storybook.id}/index.html",
      :content_type => 'text/html',
      :public       => true,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'index.html'))
    ).save
    logger.info 'Uploading of ipa file index.html completed!'
    true
  end

  def send_notification
    Resque.enqueue(MailerQueue, 'UserMailer', 'ios_compilation_completion_notification', @storybook.user.email, @storybook.compiled_application.index_html_url, @storybook.compiled_application.url)
  end

  private

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
