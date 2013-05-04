begin
  require 'cfpropertylist'
rescue LoadError
end

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
    rewrite_manifest_pl

    f = FOG_DIRECTORY.files.new(
      :key          => "compiled_applications/#{@storybook.id}/manifest.plist",
      :content_type => 'text/xml',
      :public       => true,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'manifest.plist'))
    )
    f.save
    logger.info 'Uploading of ipa file manifest.plist completed!'

    # FIXME: WA: Rewrite index html once we figure out why tapping
    # on install link in index html does not work.
    # rewrite_index_html(f)
    f = FOG_DIRECTORY.files.new(
      :key          => "compiled_applications/#{@storybook.id}/index.html",
      :content_type => 'text/html',
      :public       => false,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'index.html'))
    )
    f.save
    logger.info 'Uploading of ipa file index.html completed!'
    @index_html_url = f.url(compiled_application_url_expires)

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

  def compiled_application_url
    @compiled_application_url ||= @storybook.compiled_application.url
  end

  def compiled_application_url_expires
    @compiled_application_url_expires ||= Rack::Utils.parse_nested_query(URI.parse(compiled_application_url).query)['Expires'] || 1.hour.from_now.to_i
  end

  def send_notification
    logger.info "Enqueuing notificatoin email for storybook #{@storybook.id}"
    Resque.enqueue(MailerQueue, @storybook.user.email, @index_html_url, compiled_application_url)
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

  # TODO: WA: This is way too much work for StorybookApplication. It rewrites file that were
  # created by betabuilder. Instead of this, we should have a class that has deploy logic
  # and is pluggable in betabuilder. See for inspiration
  # https://github.com/waseem/betabuilder/blob/master/lib/beta_builder/deployment_strategies/web.rb
  def rewrite_manifest_pl
    plist = CFPropertyList::List.new(:file => File.join(CRUCIBLE_IOS_DIR, "pkg", "Payload", "#{@target}.app", "Info.plist"))
    plist_data = CFPropertyList.native_types(plist.value)
    File.open(File.join(CRUCIBLE_IOS_DIR, "pkg", "dist", "manifest.plist"), "w") do |io|
      io << %{<?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>items</key>
          <array>
            <dict>
              <key>assets</key>
              <array>
                <dict>
                  <key>kind</key>
                  <string>software-package</string>
                  <key>url</key>
                  <string>
                    #{compiled_application_url}
                  </string>
                </dict>
              </array>
              <key>metadata</key>
              <dict>
                <key>bundle-identifier</key>
                <string>#{plist_data['CFBundleIdentifier']}</string>
                <key>bundle-version</key>
                <string>#{plist_data['CFBundleVersion']}</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>#{plist_data['CFBundleDisplayName']}</string>
              </dict>
            </dict>
          </array>
        </dict>
        </plist>
      }
    end
  end

  def rewrite_index_html(manifest_pl)
    File.open(File.join(CRUCIBLE_IOS_DIR, "pkg", "dist", "index.html"), "w") do |io|
      io << %{
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
        <title>Beta Download</title>
        <style type="text/css">
        body {background:#fff;margin:0;padding:0;font-family:arial,helvetica,sans-serif;text-align:center;padding:10px;color:#333;font-size:16px;}
        #container {width:300px;margin:0 auto;}
        h1 {margin:0;padding:0;font-size:14px;}
        p {font-size:13px;}
        .link {background:#ecf5ff;border-top:1px solid #fff;border:1px solid #dfebf8;margin-top:.5em;padding:.3em;}
        .link a {text-decoration:none;font-size:15px;display:block;color:#069;}
        </style>
        </head>
        <body>
        <div id="container">
        <div class="link"><a href="itms-services://?action=download-manifest&url=#{manifest_pl.url(compiled_application_url_expires)}">Tap Here to Install<br />#{@target}<br />On Your Device</a></div>
        <p><strong>Link didn't work?</strong><br />
        Make sure you're visiting this page on your device, not your computer.</p>
        </body>
        </html>
      }
    end
  end
end
