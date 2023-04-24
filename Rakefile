require 'bundler/gem_tasks'
require 'rake/testtask'
require 'bundler'

gemspec = eval(File.read(Dir['*.gemspec'].first))
gemfile = [gemspec.name, gemspec.version].join('-') + '.gem'

desc 'Validate gemspec'
task :gemspec do
  gemspec.validate
end

desc 'Run minitest'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'spec'
    t.test_files = FileList['spec/**/*_spec.rb']
    t.warning = true
    t.verbose = true
  end
end

desc 'Build gem'
task :build

desc 'Install gem'
task install: :build do
  system "sudo -E sh -c 'umask 022; gem install gems/#{gemfile}'"
end

desc 'Remove gems'
task :clean do
  FileUtils.rm_rf 'pkg'
end

desc 'Push to rubygems'
task :push do
  system "gem push pkg/#{gemfile}"
end

task default: :test
