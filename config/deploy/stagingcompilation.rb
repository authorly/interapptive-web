set :user,            "Xcloud"
set :deploy_to,       "/Users/#{user}/apps/#{application}"
set :bundle_flags,    '--deployment'
set :bundle_without,  [:development, :test, :assets]
set :rvm_ruby_string, '1.9.3'

role :stagingcompilation, "80.74.134.138"
