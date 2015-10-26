require_relative 'lib/go4rake/version.rb'

task :default => :install

task :install => :build do
  sh 'sudo gem install go4rake-#{Go4Rake:Version}'
end

task :build do
  sh 'gem build go4rake.gemspec'
end

task :clean do
  rm Dir.glob('*.gem')
end
