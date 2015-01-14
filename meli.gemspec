# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meli/version'

Gem::Specification.new do |spec|
  spec.name          = "meli"
  spec.version       = Meli::VERSION
  spec.authors       = ["Gullit Miranda, Marcus Gadbem"]
  spec.email         = ["gullitmiranda@gmail.com", "mcsgad@gmail.com"]
  spec.summary       = %q{Meli gem interacts with the official API Mercadolibre.}
  spec.description   = %q{Meli gem interacts with the official API Mercadolibre.}
  spec.homepage      = "https://bitbucket.org/aircrm/meli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency 'rake', '~> 10.3', '>= 10.3.2'

  spec.add_development_dependency 'rspec', '~> 3.0', '>= 3.0.0'
  spec.add_development_dependency 'rspec-nc', '~> 0.1', '>= 0.1.0'

  spec.add_development_dependency 'guard', '~> 2.6', '>= 2.6.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.3', '>= 4.3.1'

  spec.add_runtime_dependency 'activeresource', '~> 4.0', '>= 4.0.0'
  spec.add_runtime_dependency 'oauth2', '~> 1.0', '>= 1.0.0'
end
