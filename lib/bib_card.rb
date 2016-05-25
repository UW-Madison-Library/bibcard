require "openssl"
require "rdf"
require "rdf/rdfxml"
require "spira"
require "rest-client"

require "bib_card/version"
require "bib_card/uris"
require "bib_card/author"
require "bib_card/person"
require "bib_card/crawler"
require "bib_card/db_pedia/resource"
require "bib_card/getty/scope_note"
require "bib_card/getty/source"
require "bib_card/getty/subject"
require "bib_card/wikidata/entity"

module BibCard

  def self.person_data(uri)
    graph, viaf_uri = creator_graph_and_viaf_uri(uri)
    graph.dump(:ntriples)
  end
  
  def self.person(uri)
    graph, viaf_uri = creator_graph_and_viaf_uri(uri)
    Spira.repository = graph
    viaf_uri.as(Person)
  end
  
  def self.viaf_uri?(uri)
    url = uri.to_s
    url.match(/^http:\/\/viaf\.org\/viaf\/\d+$/).nil? ? false : true
  end
  
  def self.lcnaf_uri?(uri)
    url = uri.to_s
    url.match(/^http:\/\/id\.loc\.gov\/authorities\/names\/no{0,1}\d+$/).nil? ? false : true
  end
  
  private
  
  def self.creator_graph_and_viaf_uri(uri)
    # Convert the URI to an RDF::URI object if it is not already
    uri = convert_uri(uri)
    
    # 1. Get the VIAF data and determine the VIAF URI
    if lcnaf_uri?(uri)
      # Load the VIAF data graph and determine the VIAF URI based on the LCNAF URI.
      identifier = lcnaf_uri_to_identifier(uri)
      viaf_url   = URI.encode("http://viaf.org/viaf/sourceID/LC|#{identifier}")
      viaf_graph = RDF::Graph.load(viaf_url, format: :rdfxml)
      viaf_uri   = viaf_graph.query(predicate: SCHEMA_SAME_AS, object: uri).first.subject
    elsif viaf_uri?(uri)
      # Load the VIAF data graph using the URI
      viaf_uri   = uri
      viaf_graph = RDF::Graph.load(uri, format: :rdfxml)
    end
    
    # 2. Crawl and use it as a basis for crawling the other data sources 
    crawler = Crawler.new(viaf_uri, viaf_graph)
    graph = crawler.creator_graph
    [graph, viaf_uri]
  end
  
  def self.lcnaf_uri_to_identifier(uri)
    url = uri.to_s
    url.gsub("http://id.loc.gov/authorities/names/", "")
  end
  
  # Convert
  def self.convert_uri(uri)
    uri.is_a?(RDF::URI) ? uri : RDF::URI.new(uri)
  end
  
end
