# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apibanca/client/version'

Gem::Specification.new do |spec|
  spec.name          = "apibanca-client"
  spec.version       = Apibanca::Client::VERSION
  spec.authors       = ["Pablo Marambio"]
  spec.email         = ["yo@pablomarambio.cl"]
  spec.summary       = "Cliente de API-Banca"
  spec.description   = "Cliente de API-Banca"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"

  spec.add_dependency "hashie"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
end
