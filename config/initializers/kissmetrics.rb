# :log_dir is not specified. By default it is /tmp
unless Rails.env == 'test'
  KMTS.init(YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'kissmetrics.yml'))).result)[Rails.env])
end
