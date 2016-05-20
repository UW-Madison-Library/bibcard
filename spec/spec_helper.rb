$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bib_card'
require 'webmock/rspec'

def body_content(path)
  File.read("#{File.expand_path(File.dirname(__FILE__))}/support/#{path}")
end