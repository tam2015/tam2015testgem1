# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meli/version'

Gem::Specification.new do |spec|
  spec.name          = "meli"
  spec.version       = Meli::VERSION
  spec.authors       = ["Gullit Miranda"]
  spec.email         = ["gullitmiranda@gmail.com"]
  spec.summary       = %q{Meli gem interacts with the official API Mercadolibre.}
  spec.description   = %q{Meli gem interacts with the official API Mercadolibre.}
  spec.homepage      = "https://github.com/gullitmiranda/meli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"

  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"

  spec.add_runtime_dependency 'activeresource'#, '>= 4.0'
  spec.add_runtime_dependency 'oauth2', '~> 0.9.3'
end
