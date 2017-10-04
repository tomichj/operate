# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'operate/version'

Gem::Specification.new do |spec|
  spec.name          = 'operate'
  spec.version       = Operate::VERSION
  spec.authors       = ['Justin Tomich']
  spec.email         = ['tomichj@gmail.com']

  spec.summary       = 'Create service objects with Operate.'
  spec.description   = 'Create service objects with Operate.'
  spec.homepage      = 'https://github.com/tomichj/operate'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'activerecord', '>= 4.2.0'
  spec.add_development_dependency 'sqlite3'
end
