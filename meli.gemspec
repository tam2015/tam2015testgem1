# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meli/version'

Gem::Specification.new do |spec|
  spec.name          = "meli"
  spec.version       = Meli::VERSION
  spec.authors       = ["Gullit Miranda"]
  spec.email         = ["gullitmiranda@gmail.com"]
  spec.summary       = %q{Connect to Mercadolibre through Meli API}
  spec.description   = %q{Connect to Mercadolibre through Meli API}
  spec.homepage      = ""
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

  spec.add_development_dependency "coveralls"

  spec.add_runtime_dependency "crimp"
end
