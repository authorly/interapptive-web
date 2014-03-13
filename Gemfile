source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem 'mysql2'
gem 'bcrypt-ruby'
gem 'jquery-rails'
gem 'haml'
gem 'less-rails-bootstrap'
gem 'carrierwave'
gem 'zencoder'
gem 'fog'
gem 'unf' # http://stackoverflow.com/questions/19666226/warning-with-fog-and-aws-unable-to-load-the-unf-gem
gem 'mini_magick', '3.4'
gem 'param_protected', '~> 4.0.0'
gem 'unicorn'
gem 'therubyracer', '~> 0.12.1'
gem 'barista'
gem 'ttfunk'
gem 'resque'
gem 'resque-loner'
gem 'god'
gem 'yaml_db'
gem 'kaminari'
gem 'airbrake'
gem 'high_voltage'
gem 'kmts', '~>2.0.0'

group :osx do
  gem 'betabuilder', :git => 'git://github.com/waseem/betabuilder.git', :branch => 'no_deploy', :ref => '1125dab2d903fb24aabef758d0f1feb22940ed6a'
end

group :assets do
  gem 'less-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'haml_coffee_assets'
  gem 'execjs'
end

group :development, :test do
  gem 'jasminerice'

  gem 'guard'
  gem 'guard-jasmine'
  gem 'guard-rspec'
  gem 'rb-fsevent', '~> 0.9'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'haml-rails'
  gem 'debugger'
  gem 'growl'
  gem 'zencoder-fetcher'
end

group :test do
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'poltergeist'
  gem 'miniskirt'
  gem 'database_cleaner'
  gem 'ffaker'
  gem 'forgery'
  gem 'launchy'
  gem 'connection_pool'
end

group :deployment do
  gem 'capistrano'
  gem 'rvm-capistrano'
end
