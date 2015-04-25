# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mlk/version'

Gem::Specification.new do |spec|
  spec.name          = 'mlk'
  spec.version       = Mlk::VERSION
  spec.authors       = ['Sven Pfleiderer']
  spec.email         = ['sg+github@roothausen.de']
  spec.description   = %q{mlk is a model framework based on YAML-annotated Markdown files}
  spec.summary       = %q{A model framework based on YAML-annotated Markdown files}
  spec.homepage      = 'https://github.com/pfleidi/mlk'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'scrivener'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
end
