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

  # Note that this is a less than ideal way to instantiate a BibCard::Person object.
  # At the time of writing the Alma vendor platform returns author objects in the following format:
  #
  #   {
  #     "@id":"http://id.loc.gov/authorities/names/n79032058",
  #     "label":"Wittgenstein, Ludwig, 1889-1951.",
  #     "sameAs":"http://viaf.org/viaf/sourceID/LC|n79032058"
  #   }
  #
  # Ultimately what we want is the VIAF URI and this is the best hack for resolving from the LC URI 
  # and VIAF URL to the VIAF URI like http://viaf.org/viaf/24609378
  def self.author_from_viaf_lc(viaf_url, lc_uri)
    # First load the VIAF data...
    viaf_graph = RDF::Graph.load(URI.encode(viaf_url), format: :rdfxml)
    viaf_uri   = viaf_graph.query(predicate: SCHEMA_SAME_AS, object: RDF::URI.new(lc_uri)).first.subject
    crawler    = Crawler.new(viaf_uri, viaf_graph)
    
    # and use it as a basis for crawling the other data sources 
    Spira.repository = crawler.creator_graph
    viaf_uri.as(Person)
  end
  
  # Given a VIAF URI, give me the raw data as N-Triples required to construct a BibCard
  def self.ntriples_for_viaf(uri)
    viaf_graph = RDF::Graph.load(uri, format: :rdfxml)
    crawler = Crawler.new(uri, viaf_graph)
    crawler.creator_graph.dump(:ntriples)
  end
  
  # Given a VIAF URL, give me the raw data as N-Triples required to construct a BibCard
  def self.ntriples_for_lcnaf_id(lcnaf_id)
    crawler = self.viaf_crawler_for_lcnaf_id(lcnaf_id)
    crawler.creator_graph.dump(:ntriples)
  end
  
  private 
  
  def self.viaf_crawler_for_lcnaf_id(lcnaf_id)
    viaf_url   = "http://viaf.org/viaf/sourceID/LC|#{lcnaf_id}"
    lc_uri     = "http://id.loc.gov/authorities/names/#{lcnaf_id}"
    viaf_graph = RDF::Graph.load(URI.encode(viaf_url), format: :rdfxml)
    viaf_uri   = viaf_graph.query(predicate: SCHEMA_SAME_AS, object: RDF::URI.new(lc_uri)).first.subject
    
    Crawler.new(viaf_uri, viaf_graph)
  end

end
