require 'rubygems'
require 'rake'
require 'rake/clean'
require 'sprout'
require 'sprout/tasks/sftp_task'

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sprout-as3playdar-src-library #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

FILES = File.join(File.dirname(__FILE__), 'lib')
PKG = File.join(File.dirname(__FILE__), 'pkg')
ARTIFACTS = ENV['CC_BUILD_ARTIFACTS'] || 'artifact'

Dir.glob("#{FILES}/**").each do |file|
  load file

  name = File.basename(file).split('.rb').join('')
  task :package => name
end

CLEAN.add(PKG)

desc "Package all libraries as gems"
task :package do
  Dir.glob("#{PKG}/**").each do |file|
    if(File.directory?(file))
      FileUtils.rm_rf(file)
    end
  end
end

desc "Increment Revision"
task :increment_revision do
  # library tasks should be incremented independently...
end

task :default => :"as3playdar-src"
