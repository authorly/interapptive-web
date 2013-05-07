set :user,            "rails"
set :deploy_to,       "/home/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :assets, :osx]
set :rvm_ruby_string, '1.9.3'
set :rails_env,       "staging"

role :androidcompilation, "173.255.214.98"

namespace :god do
  desc "Ask god to restart Resque"
  task :restart, :roles => :androidcompilation do
    run("cd #{deploy_to}/current; . script/restart_authorly_god.sh")
  end
end

namespace :deploy do
  desc "Copy database.yml and other configuration files from shared/ to config/"
  task :copy_god_restart_script, :roles => :androidcompilation do 
    run "cp #{shared_path}/script/restart_authorly_god.sh #{release_path}/script/"
  end

  desc "Copies ActionMailer configuration file to config"
  task :copy_action_mailer_options, :roles => :androidcompilation do
    run "cp #{shared_path}/config/action_mailer.yml #{release_path}/config"
  end
end

after 'deploy:update_code', 'deploy:copy_god_restart_script', 'deploy:copy_action_mailer_options'
after "deploy:restart", 'god:restart'
