require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the redmine_datacenter plugin.'
Rake::TestTask.new(:test) do |t|
  ENV['RAILS_ENV'] = 'test'
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the redmine_datacenter plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'redmine_datacenter'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Prepares tests'
task :prepare_tests do |t|
  require 'open3'
  FileUtils.chdir('..')
  cmd = "rake db:migrate:all db:fixtures:load db:fixtures:plugins:load test:plugins:setup_plugin_fixtures"
  cmd << " RAILS_ENV=test PLUGIN=redmine_datacenter NAME=redmine_datacenter"
  Open3.popen3(cmd) do |stdin,stdout,stderr|
    puts stdout.read
    $stderr.puts stderr.read
  end
end
