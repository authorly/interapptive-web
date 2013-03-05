#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Interapptive::Application.load_tasks

if %w(test development).include?(ENV['RAILS_ENV'])
  require 'guard/jasmine/task'
  Guard::JasmineTask.new
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task 'default' => ['guard:jasmine', 'spec']
