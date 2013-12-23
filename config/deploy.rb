require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :application,     'authorly'
set :scm,             :git
set :repository,      "git@github.com:curiousminds/interapptive-web.git"
set :branch,          "master"
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :keep_releases,   3
set :scm_verbose,     true


namespace :deploy do
  desc "Copy database.yml and other configuration files from shared/ to config/"
  task :copy_configuration_files do 
    run "cp #{shared_path}/config/database.yml #{release_path}/config/"
  end
end

after 'deploy:update_code', 'deploy:copy_configuration_files'
after 'deploy:update',      'deploy:cleanup'

        require './config/boot'
        require 'airbrake/capistrano'
