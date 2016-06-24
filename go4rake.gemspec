require_relative 'version.rb'

Gem::Specification.new do |s|
  s.name         = 'go4rake'
  s.version      = Go4Rake::Version
  s.summary      = 'Rake helper for cross-compiling Go programs'
  s.description  = '`build`, `zip, `test`` and `clean` tasks for cross-compilation of Go programs'
  s.homepage     = 'https://github.com/chillum/go4rake'
  s.license      = 'Apache-2.0'
  s.author       = 'Vasily Korytov'
  s.email        = 'vasily.korytov@icloud.com'
  s.files        = %w(NOTICE README.md examples/go4rake.yml lib/go4rake.rb lib/go4rake/new.rb)
  s.add_dependency 'rake',    '~> 10.0'
  s.add_dependency 'rubyzip', '~> 1.2'
  s.required_ruby_version   = '>= 1.9.2'
end
