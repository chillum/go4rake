require_relative 'lib/go4rake/version.rb'

task :default => :install

task :install => :build do
  sh "sudo gem install autoup-#{Go4Rake::Version}.gem"
end

task :uninstall do
  sh 'sudo gem uninstall go4rake'
end

task :push => :build do
  sh "gem push autoup-#{Go4Rake::Version}.gem"
end

task :build do
  sh 'gem build go4rake.gemspec'
end

task :clean do
  rm Dir.glob('*.gem')
end
