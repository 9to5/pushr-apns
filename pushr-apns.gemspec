$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'pushr-apns/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'pushr-apns'
  s.version     = PushrApns::VERSION
  s.authors     = ['Tom Pesman']
  s.email       = ['tom@tnux.net']
  s.homepage    = 'https://github.com/tompesman/pushr-apns'
  s.summary     = 'APNS (iOS/Apple) part of the modular push daemon.'
  s.description = 'APNS support for the modular push daemon.'

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.files         = `git ls-files lib`.split("\n") + ['README.md', 'MIT-LICENSE']
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'multi_json', '~> 1.0'
  s.add_dependency 'pushr-core'
  s.add_development_dependency 'sqlite3'
end
