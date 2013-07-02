load 'deploy/assets'

set :user,            "rails"
set :deploy_to,       "/home/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :osx]
set :rails_env,       "production"
set :branch,          "production"

# Use chruby to change ruby version for capistrano
default_run_options[:shell] = '/bin/bash'
set :ruby_version, "1.9.3-p448"
set :chruby_config, "/usr/local/share/chruby/chruby.sh"
set :set_ruby_cmd, "source #{chruby_config} && chruby #{ruby_version}"
set(:bundle_cmd) {
  "#{set_ruby_cmd} && exec bundle"
}

role :production, "ec2-50-16-195-156.compute-1.amazonaws.com"
role :app, "ec2-50-16-195-156.compute-1.amazonaws.com"
role :web, "ec2-50-16-195-156.compute-1.amazonaws.com"
role :db, "ec2-50-16-195-156.compute-1.amazonaws.com", :primary => true


namespace :deploy do
  desc "Print the environment"
  task :migration, :roles => :production do
    run "cd #{release_path} && #{bundle_cmd} exec rake db:migrate --trace RAILS_ENV=production"
  end

  task :restart_unicorn do
    run "kill -s INT $(cat #{shared_path}/pids/unicorn.pid) && sleep 5 && cd #{release_path} && #{bundle_cmd} exec unicorn_rails -E #{rails_env} -D -c /home/#{user}/apps/#{application}/shared/config/unicorn-production.rb"
  end

end


after 'deploy:update_code', 'deploy:migration'
after 'deploy:create_symlink', :roles => :app do
  deploy.restart_unicorn
end
