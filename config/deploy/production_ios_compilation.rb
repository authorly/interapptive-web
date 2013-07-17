require 'rvm/capistrano'

set :user,            "Xcloud"
set :deploy_to,       "/Users/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :assets]
set :rvm_ruby_string, '1.9.3'
set :rails_env,       "staging"

role :production_staging_compilation, "94.126.20.38"

namespace :god do
  desc "Ask god to restart Resque"
  task :restart, :roles => :production_staging_compilation do
    run("cd #{deploy_to}/current; . script/restart_authorly_god.sh")
  end
end

namespace :deploy do
  desc "Copy database.yml and other configuration files from shared/ to config/"
  task :copy_god_restart_script, :roles => :production_staging_compilation do 
    run "cp #{shared_path}/script/restart_authorly_god.sh #{release_path}/script/"
  end

  desc "Copy Gemfile and Gemfile.lock to CRUCIBLE_IOS_DIR"
  task :copy_gemfile_to_crucible, :roles => :production_staging_compilation do
    run "cp #{release_path}/.bundle/config #{shared_path}/../Crucible/HelloWorld/ios/.bundle/config"
    run "cp #{release_path}/Gemfile #{release_path}/Gemfile.lock #{shared_path}/../Crucible/HelloWorld/ios"
  end

  desc "Copies keychain unlock password file to config"
  task :copy_keychain_password, :roles => :production_staging_compilation do
    run "cp #{shared_path}/config/keychain_password.txt #{release_path}/config"
  end

  desc "Copies ActionMailer configuration file to config"
  task :copy_action_mailer_options, :roles => :production_staging_compilation do
    run "cp #{shared_path}/config/action_mailer.yml #{release_path}/config"
  end
end

after 'deploy:update_code', 'deploy:copy_god_restart_script', 'deploy:copy_keychain_password', 'deploy:copy_action_mailer_options'
after "deploy:restart", 'god:restart'
after "bundle:install", 'deploy:copy_gemfile_to_crucible'
