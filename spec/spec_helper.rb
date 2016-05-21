require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bib_card'
require 'webmock/rspec'

def body_content(path)
  File.read("#{File.expand_path(File.dirname(__FILE__))}/support/#{path}")
end

def sparql_config
  YAML.load( File.read("#{File.expand_path(File.dirname(__FILE__))}/support/sparql_queries.yml") )
end