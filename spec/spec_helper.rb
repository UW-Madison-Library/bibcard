require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bib_card'
require 'webmock/rspec'

def body_content(path)
  File.read("#{File.expand_path(File.dirname(__FILE__))}/support/#{path}")
end

def sparql_config
  YAML.load( File.read("#{File.expand_path(File.dirname(__FILE__))}/support/config.yml") )
end

def person(name)
  config = sparql_config
  stub_sparql_queries(config, name)
  uri = "http://id.loc.gov/authorities/names/#{config[name]["lcnaf_id"]}"
  
  BibCard.person(uri)
end

def stub_sparql_queries(config, name)
  stub_request(:get, config[name]["viaf_uri"]).to_return(body: body_content("viaf/LC-#{config[name]["lcnaf_id"]}.xml"), :status => 200)
  stub_request(:get, config[name]["viaf_lcnaf_url"]).to_return(body: body_content("viaf/LC-#{config[name]["lcnaf_id"]}.xml"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["profile"]).to_return(body: body_content("dbpedia/#{name}-profile.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["influences"]).to_return(body: body_content("dbpedia/#{name}-influences.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["influenced"]).to_return(body: body_content("dbpedia/#{name}-influenced.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["films"]).to_return(body: body_content("dbpedia/#{name}-films.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["getty_note"]).to_return(body: body_content("getty/#{name}-note.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["alma_maters"]).to_return(body: body_content("wikidata/#{name}-alma-maters.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["bio"]).to_return(body: body_content("wikidata/#{name}-bio.json"), :status => 200)
  stub_request(:get, config[name]["sparql_urls"]["notable_works"]).to_return(body: body_content("wikidata/#{name}-notable-works.json"), :status => 200)
end

def read_ntriples(raw)
  graph = RDF::Graph.new
  RDF::Reader.for(:ntriples).new(raw) do |reader|
    reader.each_statement {|statement| graph << statement}
  end
  graph
end