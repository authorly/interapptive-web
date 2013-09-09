set :user,            "rails"
set :deploy_to,       "/home/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :assets, :osx]
set :rails_env,       "production"

role :production_android_compilation, "ec2-54-211-199-222.compute-1.amazonaws.com"

# Use chruby to change ruby version for capistrano
default_run_options[:shell] = '/bin/bash'
set :ruby_version, "1.9.3-p448"
set :chruby_config, "/usr/local/share/chruby/chruby.sh"
set :set_ruby_cmd, "source #{chruby_config} && chruby #{ruby_version}"
set(:bundle_cmd) {
  "#{set_ruby_cmd} && exec bundle"
}

namespace :god do
  desc "Ask god to restart Resque"
  task :restart, :roles => :production_android_compilation do
    run("cd #{deploy_to}/current; . script/restart_authorly_god.sh")
  end
end

namespace :deploy do
  desc "Copy database.yml and other configuration files from shared/ to config/"
  task :copy_god_restart_script, :roles => :production_android_compilation do 
    run "cp #{shared_path}/script/restart_authorly_god.sh #{release_path}/script/"
  end

  desc "Copies ActionMailer configuration file to config"
  task :copy_action_mailer_options, :roles => :production_android_compilation do
    run "cp #{shared_path}/config/action_mailer.yml #{release_path}/config"
  end
end

after 'deploy:update_code', 'deploy:copy_god_restart_script', 'deploy:copy_action_mailer_options'
after "deploy:restart", 'god:restart'
