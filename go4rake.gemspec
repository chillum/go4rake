Gem::Specification.new do |s|
  s.name         = 'go4rake'
  s.version      = '1.0.8'
  s.summary      = 'go4rake is a Rake helper for cross-compiling Go programs'
  s.description  = '`build`, `test` and `zip` tasks for cross-compilation of Go programs'
  s.homepage     = 'https://github.com/chillum/go4rake'
  s.license      = 'Apache-2.0'
  s.author       = 'Vasily Korytov'
  s.email        = 'vasily.korytov@yahoo.com'
  s.files        = ['LICENSE.txt',  'README.md', 'examples/go4rake.yml',
                    'go4rake.gemspec', 'lib/go4rake.rb', 'lib/go4rake/new.rb']
  s.add_dependency 'rake', '~> 10.0'
end
