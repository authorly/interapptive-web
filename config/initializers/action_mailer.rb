action_mailer_options_file_path = File.join(Rails.root, 'config', 'action_mailer.yml')

if File.exist?(action_mailer_options_file_path)
  options = YAML::load(ERB.new(IO.read(action_mailer_options_file_path)).result)[Rails.env]

  if options.present?
    Rails.configuration.action_mailer_options = options.symbolize_keys
    ActionMailer::Base.smtp_settings = options.symbolize_keys.merge(
      :domain               => 'authorly.com',
      :port                 => '587',
      :authentication       => :plain,
      :enable_starttls_auto => true
    )
  end
end
