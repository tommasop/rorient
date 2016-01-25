# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'droplet_kit/version'

Gem::Specification.new do |spec|
  spec.name          = "rorient"
  spec.version       = Rorient::VERSION
  spec.authors       = ["Tommaso Patrizi"]
  spec.email         = ["tpatrizi@makeplan.it"]
  spec.summary       = %q{Rorient è una libreria ruby per OrientDB}
  spec.description   = %q{Rorient è una libreria ruby per OrientDB}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency "resource_kit", '~> 0.1.4'
  spec.add_dependency "faraday", '~> 0.9.1'

  spec.add_development_dependency "bundler", "~> 1.11.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "pry"

  # FakeServe
  # spec.add_development_dependency 'sinatra', '~> 1.4'
  # spec.add_development_dependency 'webmock', '~> 1.18'
end
