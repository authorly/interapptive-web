class StorybookApplication
  CRUCIBLE_RESOURCES_DIR = File.join(Rails.root, '../../Crucible/HelloWorld/Resources')
  CRUCIBLE_IOS_DIR       = File.join(Rails.root, '../../Crucible/HelloWorld/ios/')
  # Following should live outside of the codebase. So that
  # configurations could be changed without redeploying
  # the application.
  FOG_DIRECTORY          = Fog::Storage.new(
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAJ3N4AG2EGQRMHXRQ',
    :aws_secret_access_key  => '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'
  ).directories.get('interapptive')

  @downloadable_file_extension_regex = nil

  def initialize(storybook, storybook_json, target)
    @storybook = storybook
    @json = storybook_json
    @transient_files = []
    @target = 'testing'
    @deploy_to_url = "https://interapptive.s3.amazonaws.com/compiled_applications/#{@storybook.id}"
  end

  def logger
    Rails.logger
  end

  def download_files_and_sanitize_json(hash_or_array)
    case hash_or_array
    when Hash
      hash_or_array.each do |key, value|
        if value.is_a?(Hash) || value.is_a?(Array)
          download_files_and_sanitize_json(value)
        else
          file_name = download_file(value)
          hash_or_array[key] = file_name
        end
      end
    when Array
      hash_or_array.each_with_index do |value, key|
        if value.is_a?(Hash) || value.is_a?(Array)
          download_files_and_sanitize_json(value)
        else
          file_name = download_file(value)
          hash_or_array[key] = file_name
        end
      end
    end
    hash_or_array
  end

  def compile
    @transient_files = []
    @json_hash = download_files_and_sanitize_json(ActiveSupport::JSON.decode(@json))
    logger.info "Going to compile application with json:\n\n"
    logger.info @json_hash.inspect
    write_json_file
    write_rake_file
    xbuild_application
    @json_hash
  end

  def cleanup
    begin
      File.delete(*@transient_files)
    rescue => e
      logger.info "Cleanup failed for #{@storybook.id}"
      logger.info e.message + "\n" + e.backtrace.join("\n")
    end
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
    )
    logger.info 'Uploading of ipa file manifest.plist completed!'

    FOG_DIRECTORY.files.new(
      :key          => "compiled_applications/#{@storybook.id}/index.html",
      :content_type => 'text/html',
      :public       => true,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'index.html'))
    )
    logger.info 'Uploading of ipa file index.html completed!'
    true
  end

  def download_file(file)
    return file unless file.is_a?(String)
    file_ext = File.extname(file)

    if file_ext.match(self.class.downloadable_file_extension_regex)
      if file.match(/^http/)
        new_file_name = SecureRandom.hex
        tf = Tempfile.new([new_file_name, file_ext], CRUCIBLE_RESOURCES_DIR)
        tf.binmode
        open(file, 'rb') do |read_file|
          tf.write(read_file.read)
        end
        @transient_files << tf.path
        return File.basename(tf.path)
      elsif file.match(/^\/assets/)
        return File.basename(file)
      end
    end
    file
  end

  def send_notification
    logger.info "Enqueuing notificatoin email for storybook #{@storybook.id}"
    Resque.enqueue(MailerQueue, @storybook.user.email, @storybook.compiled_application.index_html_url, @storybook.compiled_application.url)
  end

  # Change this method to include any new uploaders to take care that
  # introduce new type of files in the application
  def self.downloadable_file_extension_regex
    return @downloadable_file_extension_regex if @downloadable_file_extension_regex

    downloadable_extensions = FontUploader.new.extension_white_list +
      ImageUploader.new.extension_white_list +
      SoundUploader.new.extension_white_list +
      VideoUploader.new.extension_white_list
    downloadable_extensions.uniq!
    @downloadable_file_extension_regex = Regexp.new(downloadable_extensions.join('|'), true) # true means case insensitive
    @downloadable_file_extension_regex
  end

  private

  def xbuild_application
    f = IO.popen("cd #{CRUCIBLE_IOS_DIR} && security unlock-keychain -p '#{Rails.application.config.crucible_keychain_password}' /Users/Xcloud/Library/Keychains/login.keychain && bundle exec rake beta:deploy --trace")
    # TODO: WA: Following blocks the worker process till log is
    # written. Fork it to child process.
    logger.info f.readlines.join
    f.close
  end

  def write_json_file
    File.open(File.join(CRUCIBLE_RESOURCES_DIR, 'structure-ipad.json'), 'w') do |f|
      f.write(ActiveSupport::JSON.encode(@json_hash))
    end
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
