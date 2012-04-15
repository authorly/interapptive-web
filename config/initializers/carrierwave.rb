CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAJ3N4AG2EGQRMHXRQ',
    :aws_secret_access_key  => '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'
  }

  config.fog_directory  = 'interapptive'
end
