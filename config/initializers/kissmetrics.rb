# :log_dir is not specified. By default it is /tmp
if Rails.env == 'test'
  KMTS.init('', dryrun: true)
else
  KMTS.init(YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'kissmetrics.yml'))).result)[Rails.env])
end
