set :user,            "Xcloud"
set :deploy_to,       "/Users/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :assets]
set :rvm_ruby_string, '1.9.3'
set :rails_env,       "staging"

role :stagingcompilation, "80.74.134.138"

namespace :god do
  desc "Ask god to restart Resque"
  task :restart, :roles => :stagingcompilation do
    run("cd #{deploy_to}/current; RAILS_ENV=#{rails_env} . bin/restart_authorly_god.sh")
  end
end

namespace :deploy do
  desc "Copy database.yml and other configuration files from shared/ to config/"
  task :copy_god_restart_script, :roles => :stagingcompilation do 
    run "cp #{shared_path}/bin/restart_authorly_god.sh #{release_path}/bin/"
  end
end

after 'deploy:update_code', 'deploy:copy_god_restart_script'
after "deploy:restart", 'god:restart'
