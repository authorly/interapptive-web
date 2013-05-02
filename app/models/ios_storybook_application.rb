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
    rewrite_manifest_pl

    f = FOG_DIRECTORY.files.new(
      :key          => "compiled_applications/#{@storybook.id}/manifest.plist",
      :content_type => 'text/xml',
      :public       => false,
      :body         => File.open(File.join(CRUCIBLE_IOS_DIR, 'pkg', 'dist', 'manifest.plist'))
    )
    f.save
    logger.info 'Uploading of ipa file manifest.plist completed!'

    rewrite_index_html(f)
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

  def compiled_application_url
    @compiled_application_url ||= @storybook.compiled_application.url
  end

  def compiled_application_url_expires
    @compiled_application_url_expires ||= Rack::Utils.parse_nested_query(URI.parse(compiled_application_url).query)['Expires']
  end

  def send_notification
    logger.info "Enqueuing notificatoin email for storybook #{@storybook.id}"
    Resque.enqueue(MailerQueue, 'UserMailer', 'ios_compilation_completion_notification', @storybook.user.email, @index_html_url, compiled_application_url)
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

  # TODO: WA: This is way too much work for StorybookApplication. It rewrites file that were
  # created by betabuilder. Instead of this, we should have a class that has deploy logic
  # and is pluggable in betabuilder. See for inspiration
  # https://github.com/waseem/betabuilder/blob/master/lib/beta_builder/deployment_strategies/web.rb
  def rewrite_manifest_pl
    plist = CFPropertyList::List.new(:file => File.join(CRUCIBLE_IOS_DIR, "pkg", "Payload", "#{@target}.app", "Info.plist"))
    plist_data = CFPropertyList.native_types(plist.value)
    File.open(File.join(CRUCIBLE_IOS_DIR, "pkg", "dist", "manifest.plist"), "w") do |io|
      io << %{
        <?xml version="1.0" encoding="UTF-8"?>
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
                  <string>#{compiled_application_url}</string>
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
