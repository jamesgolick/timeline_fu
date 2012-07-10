require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'bundler/gem_tasks'
require 'appraisal'

desc 'Default: run unit tests against all supported versions of ActiveRecord'
task :default => ["appraisal:install"] do |t|
  exec("rake appraisal test")
end

desc 'Test the timeline_fu plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the timeline_fu plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TimelineFu'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
