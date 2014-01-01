load 'deploy/assets'

set :user,            "rails"
set :deploy_to,       "/home/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :osx]
set :rails_env,       "staging"
set :branch,          'master'

# Use chruby to change ruby version for capistrano
default_run_options[:shell] = '/bin/bash'
set :ruby_version, "1.9.3-p484"
set :chruby_config, "/usr/local/share/chruby/chruby.sh"
set :set_ruby_cmd, "source #{chruby_config} && chruby #{ruby_version}"
set(:bundle_cmd) {
  "#{set_ruby_cmd} && exec bundle"
}

role :staging, "staging.authorly.com"
role :app, "staging.authorly.com"
role :web, "staging.authorly.com"
role :db, "staging.authorly.com", :primary => true


namespace :deploy do
  desc "Print the environment"
  task :migration, :roles => :staging do
    run "cd #{release_path} && #{bundle_cmd} exec rake db:migrate --trace RAILS_ENV=staging"
  end

  desc "Restart the unicorn"
  task :restart_unicorn do
    run "kill -s INT $(cat #{shared_path}/pids/unicorn.pid) && sleep 5 && cd #{release_path} && #{bundle_cmd} exec unicorn_rails -E #{rails_env} -D -c /home/#{user}/apps/#{application}/shared/config/unicorn-staging.rb"
  end

  namespace :web do
    desc 'Put application in maintenance mode'
    task :disable, :roles => :staging do
      run "cp #{shared_path}/system/maintenance.html #{current_path}/public/"
    end

    desc 'Bring application back from maintenance mode.'
    task :enable, :roles => :staging do
      run "rm -f #{current_path}/public/maintenance.html"
    end
  end
end


after 'deploy:update_code', 'deploy:migration'
after 'deploy:create_symlink', :roles => :app do
  deploy.restart_unicorn
end
