require "bundler/capistrano"
require 'capistrano/ext/multistage'
require 'rvm/capistrano'

set :application,     'authorly'
set :scm,             :git
set :repository,      "git@github.com:curiousminds/interapptive-web.git"
set :branch,          "master"
set :use_sudo,        false
set :deploy_via,      :remote_cache


namespace :deploy do
  desc "Copy database.yml and other configuration files from shared/ to config/"
  task :copy_configuration_files do 
    run "cp #{shared_path}/database.yml #{release_path}/config/"
  end
end
after 'deploy:update_code', 'deploy:copy_configuration_files'
