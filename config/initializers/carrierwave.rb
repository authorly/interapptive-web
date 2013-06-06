Rails.configuration.s3_credentials = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 's3.yml'))).result)[Rails.env].symbolize_keys

CarrierWave.configure do |config|
  config.fog_credentials = {
    :region                 => 'us-east-1'
  }.merge(Rails.application.config.s3_credentials)

  config.fog_directory  = 'interapptive'
end
