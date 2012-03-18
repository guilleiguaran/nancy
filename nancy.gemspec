# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nancy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Guillermo Iguaran"]
  gem.email         = ["guilleiguaran@gmail.com"]
  gem.description   = %q{Sinatra's little daughter}
  gem.summary       = %q{Ruby Microframework inspired in Sinatra}
  gem.homepage      = "https://github.com/guilleiguaran/nancy"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "nancy"
  gem.require_paths = ["lib"]
  gem.version       = Nancy::VERSION

  gem.add_dependency 'rack'
  gem.add_dependency 'tilt'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rack-test'
end
