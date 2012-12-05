Rails.configuration.long_audio_aligner_configuration = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'long_audio_aligner.yml'))).result)[Rails.env].symbolize_keys
