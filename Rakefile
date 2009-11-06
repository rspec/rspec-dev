require 'rubygems'
require 'rake'
require 'fileutils'
require 'pathname'

def run_command(command)
  ['meta', 'core', 'expectations', 'mocks'].each do |dir|
    path = ReposPath.join(dir)
    FileUtils.cd(path) do
      puts "====================================="
      puts "Running [#{command}] in #{path}"
      puts "====================================="
      system command
      exit(1) unless $?.success?
      puts 
    end
  end
end

BaseRspecPath = Pathname.new(Dir.pwd)
ReposPath = BaseRspecPath.join('repos')

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

task :clobber do
  rm_rf 'pkg'
  rm_rf 'repos'
end

task :spec do
  run_command 'rake'# 'rake --trace --verbose'
end

task :default => ['git:clone', :spec]
