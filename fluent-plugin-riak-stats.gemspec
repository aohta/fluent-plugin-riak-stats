# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-riak-stats"
  spec.version       = "0.0.1"
  spec.authors       = ["t"]
  spec.email         = [""]
  spec.description   = %q{Riak Stats input plugin for Fluent event collector}
  spec.summary       = %q{Riak Stats input plugin for Fluent event collector}
  spec.homepage      = ""
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "fluentd"
end
