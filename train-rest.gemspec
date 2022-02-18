lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "train-rest/version"

Gem::Specification.new do |spec|
  spec.name          = "train-rest"
  spec.version       = TrainPlugins::Rest::VERSION
  spec.authors       = ["Thomas Heinen"]
  spec.email         = ["theinen@tecracer.de"]
  spec.summary       = "Train transport for REST"
  spec.description   = "Provides a transport to communicate easily with RESTful APIs."
  spec.homepage      = "https://github.com/tecracer-chef/train-rest"
  spec.license       = "Apache-2.0"

  spec.files = %w{
    README.md train-rest.gemspec Gemfile
  } + Dir.glob(
    "lib/**/*", File::FNM_DOTMATCH
  ).reject { |f| File.directory?(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "train-core", "~> 3.0"
  spec.add_dependency "rest-client", "~> 2.1"

  spec.add_development_dependency "bump", "~> 0.9"
  spec.add_development_dependency "chefstyle", "~> 0.14"
  spec.add_development_dependency "guard", "~> 2.16"
  spec.add_development_dependency "mdl", "~> 0.9"
  spec.add_development_dependency "rake", "~> 13.0"
end
