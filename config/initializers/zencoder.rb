Zencoder.api_key = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'zencoder.yml'))).result)[Rails.env].symbolize_keys[:api_key]
