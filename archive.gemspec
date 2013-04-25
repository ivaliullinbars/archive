# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'archive/version'

Gem::Specification.new do |spec|
  spec.name          = "archive"
  spec.version       = Archive::VERSION
  spec.authors       = ["Erik Hollensbe"]
  spec.email         = ["erik+github@hollensbe.org"]
  spec.description   = %q{Simple library to manage tar and zip archives with libarchive and FFI}
  spec.summary       = %q{Simple library to manage tar and zip archives with libarchive and FFI}
  spec.homepage      = "https://github.com/erikh/archive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'ffi', '~> 1.8.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-rake', '~> 0.0.8'
  spec.add_development_dependency 'rdoc', '~> 4.0'
  spec.add_development_dependency 'rb-fsevent'
  spec.add_development_dependency 'simplecov'
end
