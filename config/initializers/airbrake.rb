Rails.configuration.airbrake = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'airbrake.yml'))).result)[Rails.env].symbolize_keys
