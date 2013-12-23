load 'deploy/assets'

set :user,            "rails"
set :deploy_to,       "/home/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :osx]
set :rails_env,       "production"
set :branch do
  default_tag = `git tag`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end

# Use chruby to change ruby version for capistrano
default_run_options[:shell] = '/bin/bash'
set :ruby_version, "1.9.3-p448"
set :chruby_config, "/usr/local/share/chruby/chruby.sh"
set :set_ruby_cmd, "source #{chruby_config} && chruby #{ruby_version}"
set(:bundle_cmd) {
  "#{set_ruby_cmd} && exec bundle"
}

role :production, "beta.authorly.com"
role :app, "beta.authorly.com"
role :web, "beta.authorly.com"
role :db, "beta.authorly.com", :primary => true


namespace :deploy do
  desc "Print the environment"
  task :migration, :roles => :production do
    run "cd #{release_path} && #{bundle_cmd} exec rake db:migrate --trace RAILS_ENV=production"
  end

  desc "Restart the unicorn"
  task :restart_unicorn do
    run "kill -s INT $(cat #{shared_path}/pids/unicorn.pid) && sleep 5 && cd #{release_path} && #{bundle_cmd} exec unicorn_rails -E #{rails_env} -D -c /home/#{user}/apps/#{application}/shared/config/unicorn-production.rb"
  end

  namespace :web do
    desc 'Put application in maintenance mode'
    task :disable, :roles => :production do
      run "cp #{shared_path}/system/maintenance.html #{current_path}/public/"
    end

    desc 'Bring application back from maintenance mode.'
    task :enable, :roles => :production do
      run "rm -f #{current_path}/public/maintenance.html"
    end
  end
end


after 'deploy:update_code', 'deploy:migration'
after 'deploy:create_symlink', :roles => :app do
  deploy.restart_unicorn
end
