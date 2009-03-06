require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'radiant'

PKG_NAME = 'radiant'
PKG_VERSION = Radiant::Version.to_s
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RUBY_FORGE_PROJECT = PKG_NAME
RUBY_FORGE_USER = ENV['RUBY_FORGE_USER'] || 'jlong'

RELEASE_NAME  = PKG_VERSION
RUBY_FORGE_GROUPID = '1337'
RUBY_FORGE_PACKAGEID = '1638'

RDOC_TITLE = "Radiant -- Publishing for Small Teams"
RDOC_EXTRAS = ["README", "CONTRIBUTORS", "CHANGELOG", "INSTALL", "LICENSE"]

namespace 'radiant' do
  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = 'A no-fluff content management system designed for small teams.'
    s.description = "Radiant is a simple and powerful publishing system designed for small teams.\nIt is built with Rails and is similar to Textpattern or MovableType, but is\na general purpose content managment system--not merely a blogging engine."
    s.homepage = 'http://radiantcms.org'
    s.rubyforge_project = RUBY_FORGE_PROJECT
    s.platform = Gem::Platform::RUBY
    s.bindir = 'bin'
    s.executables = (Dir['bin/*'] + Dir['scripts/*']).map { |file| File.basename(file) } 
    s.add_dependency 'rake', '>= 0.7.1'
    s.autorequire = 'radiant'
    s.has_rdoc = true
    s.rdoc_options << '--title' << RDOC_TITLE << '--line-numbers' << '--main' << 'README'
    rdoc_excludes = Dir["**"].reject { |f| !File.directory? f }
    rdoc_excludes.each do |e|
      s.rdoc_options << '--exclude' << e
    end
    s.extra_rdoc_files = RDOC_EXTRAS
    files = FileList['**/*']
    files.include 'public/.htaccess'
    files.exclude '**/._*'
    files.exclude '**/*.rej'
    files.exclude 'cache/*'
    files.exclude 'config/database.yml'
    files.exclude 'config/locomotive.yml'
    files.exclude 'config/lighttpd.conf'
    files.exclude 'config/mongrel_mimes.yml'
    files.exclude 'db/*.db'
    files.exclude 'doc'
    files.exclude 'log/*.log'
    files.exclude 'log/*.pid'
    files.include 'log/.keep'
    files.exclude 'pkg'
    files.exclude 'tmp'
    s.files = files.to_a
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

  desc "Uninstall Gem"
  task :uninstall_gem do
    sh "gem uninstall #{PKG_NAME}" rescue nil
  end

  desc "Build and install Gem from source"
  task :install_gem => [:package, :uninstall_gem] do
    chdir("#{RADIANT_ROOT}/pkg") do
      latest = Dir["#{PKG_NAME}-*.gem"].last
      sh "gem install #{latest}"
    end
  end

  desc "Publish the release files to RubyForge."
  task :release => [:gem, :package] do
    files = ["gem", "tgz", "zip"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }

    system %{rubyforge login --username #{RUBY_FORGE_USER}}
  
    files.each do |file|
      system %{rubyforge add_release #{RUBY_FORGE_GROUPID} #{RUBY_FORGE_PACKAGEID} "#{RELEASE_NAME}" #{file}}
    end
  end
end