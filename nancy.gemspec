require File.expand_path("../lib/nancy/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Guillermo Iguaran", "Jon Raphaelson"]
  gem.email         = ["guilleiguaran@gmail.com", "jon@accidental.cc"]
  gem.description   = "Sinatra's little daughter"
  gem.summary       = "Ruby Microframework inspired in Sinatra"
  gem.homepage      = "http://guilleiguaran.github.com/nancy"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "nancy"
  gem.require_paths = ["lib"]
  gem.version       = Nancy::VERSION

  gem.required_ruby_version = ">= 2.7", "< 4"

  gem.add_dependency "rack"
  gem.add_dependency "mustermann"
end
