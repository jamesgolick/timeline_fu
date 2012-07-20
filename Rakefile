require 'rake'
require 'appraisal'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'

desc 'Default: run unit tests against all supported versions of ActiveRecord'
task default: ['appraisal:install'] do |t|
  exec('rake appraisal test')
end

desc 'Test the timeline_fu plugin.'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--backtrace']
end

desc 'Generate documentation for the timeline_fu plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TimelineFu'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
