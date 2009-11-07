require 'rubygems'
require 'rake'
require 'fileutils'
require 'pathname'

Projects = ['meta', 'core', 'expectations', 'mocks']
BaseRspecPath = Pathname.new(Dir.pwd)
ReposPath = BaseRspecPath.join('repos')

def run_command(command)
  Projects.each do |dir|
    path = ReposPath.join(dir)
    FileUtils.cd(path) do
      puts "====================================="
      puts "Running [#{command}] in #{path}"
      puts "====================================="
      system command
      puts 
    end
  end
end

task :make_repos_directory do
  FileUtils.mkdir_p ReposPath
end

def build_version_string(project_name, major, minor, tiny, pre)
version = <<versionstring
module Rspec # :nodoc:
  module #{project_name.capitalize} # :nodoc:
    module Version # :nodoc:
      unless defined?(MAJOR)
        MAJOR  = #{major}
        MINOR  = #{minor}
        TINY   = #{tiny}
        PRE    = '#{pre}'

        STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

        SUMMARY = "rspec-#{project_name.downcase} " + STRING
      end
    end
  end
end
versionstring
end

task :write_version do
  major, minor, tiny, pre = ENV['MAJOR'], ENV['MINOR'], ENV['TINY'], ENV['PRE']
  raise("You must supply MAJOR, MINOR, TINY, and PRE versions") if [major, minor, tiny, pre].any? { |v| v.nil? } 
  Projects.each do |project|
    version_string = build_version_string(project, major, minor, tiny, pre) 
    file = "repos/#{project}/lib/rspec/#{project}/version.rb"
    FileUtils.rm_rf file
    File.open(file, "w+") { |f| f << version_string }
    puts "Writing out version #{major}.#{minor}.#{tiny}.#{pre} for #{project}"
  end
end

namespace :git do

  { :status => nil,
    :pull => '--rebase',
    :push => nil,
    :reset => '--hard',
    :diff => nil
  }.each do |command, options|
    desc "git #{command} on all the repos"
    task command => :clone do
      run_command "git #{command} #{options}".strip
    end
  end

  task :st => :status

  desc "git clone all the repos the first time"
  task :clone => :make_repos_directory do
    FileUtils.cd(ReposPath) do
      ['core', 'expectations', 'mocks', 'meta'].each do |repo|
        unless File.exists?(repo)
          system "git clone git@github.com:rspec/#{repo}.git"
        end
      end
    end
  end
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'repos'
end

task :spec do
  run_command 'rake'
end

task :gemspec do
  run_command 'rake gemspec'
end

task :default => ['git:clone', :spec]
