Rails.configuration.s3_credentials = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 's3.yml'))).result)[Rails.env].symbolize_keys
Rails.configuration.s3_bucket      = 'authorly-' + Rails.env

CarrierWave.configure do |config|
  config.fog_credentials = {
    :region                 => 'us-east-1'
  }.merge(Rails.application.config.s3_credentials)

  config.fog_directory  = Rails.application.config.s3_bucket
  # Forcing use of HTTP
  config.asset_host = "http://#{config.fog_directory}.s3.amazonaws.com"
end

if Rails.env.test?
  CarrierWave.configure do |config|
    config.enable_processing = false
  end
end
