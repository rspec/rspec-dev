require 'rubygems'
require 'rake'
require 'fileutils'
require 'pathname'

def run_command(command)
  ['meta', 'core', 'expectations', 'mocks'].each do |dir|
    FileUtils.cd(ReposPath) do
      puts "====================================="
      puts "Running [#{command}] in #{ReposPath.join(dir)}"
      puts "====================================="
      FileUtils.cd(ReposPath.join(dir)) do
        system command
      end
      puts 
    end
  end
end

task :clobber do
  rm_rf 'pkg'
end

task :spec do
  run_command 'rake'
end

task :default => :spec


BaseRspecPath = Pathname.new(Dir.pwd)
ReposPath = BaseRspecPath.join('repos')

def make_repos_directory
end

task :make_repos_directory do
  FileUtils.mkdir_p ReposPath
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
          system "git clone git://github.com/rspec/#{repo}.git"
        end
      end
    end
  end
end
