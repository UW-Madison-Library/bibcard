# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bib_card/version'

Gem::Specification.new do |spec|
  spec.name          = "bib_card"
  spec.version       = BibCard::VERSION
  spec.authors       = ["Steve Meyer"]
  spec.email         = ["stephen.meyer@wisc.edu"]

  spec.summary       = %q{Library Linked Data for building knowledge cards.}
  spec.description   = %q{Given a URI for a bibliographic author entity, assemble useful information for producing a knowledge card.}
  spec.homepage      = "https://github.com/UW-Madison-Library/bibcard.git"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rdf", "~> 3.0", ">= 3.0.1"
  spec.add_runtime_dependency "rdf-vocab", "~> 3.0"
  spec.add_runtime_dependency "rdf-rdfxml", "~> 2.2.1"
  spec.add_runtime_dependency "spira", "~> 3.0"
  spec.add_runtime_dependency "rest-client", '~> 2.0.2'
  spec.add_runtime_dependency "nokogiri", ">= 1.6.3"
  spec.add_runtime_dependency "equivalent-xml", "~> 0.6"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.11", ">= 0.11.2"
  spec.add_development_dependency "webmock", "~> 2.0", ">= 2.0.3"
end
