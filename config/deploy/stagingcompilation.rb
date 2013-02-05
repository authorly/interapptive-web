set :user,            "Xcloud"
set :deploy_to,       "/Users/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :assets]
set :rvm_ruby_string, '1.9.3'
set :rails_env,       "staging"

role :stagingcompilation, "80.74.134.138"

namespace :god do
  desc "Stop God"
  task :stop, :roles => :stagingcompilation do
    run("cd #{deploy_to}/current; RAILS_ENV=#{rails_env} script/delayed_job stop")
  end
end

#after "deploy:restart", "god:stop", "god:start"
