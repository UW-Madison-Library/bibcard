require "openssl"
require "rdf"
require "rdf/rdfxml"
require "rdf/xsd"
require "spira"
require "rest-client"
require "json"

require "bib_card/version"
require "bib_card/uris"
require "bib_card/author"
require "bib_card/person"
require "bib_card/crawler"
require "bib_card/invalid_uri_exception"
require "bib_card/entity_not_found_exception"
require "bib_card/crawl_exception"
require "bib_card/db_pedia/resource"
require "bib_card/getty/scope_note"
require "bib_card/getty/source"
require "bib_card/getty/subject"
require "bib_card/wikidata/entity"

module BibCard

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.progname = self.name
        logger.formatter = proc do |severity, time, progname, msg|
          "#{severity} [#{time.strftime('%Y-%m-%d %H:%M:%S.%L')}] #{progname}: #{msg}\n"
        end
      end
    end

    def person_data(uri)
      graph, viaf_uri = creator_graph_and_viaf_uri(uri)
      graph.dump(:ntriples)
    end

    def person(uri)
      graph, viaf_uri = creator_graph_and_viaf_uri(uri)
      Spira.repository = graph
      viaf_uri.as(Person)
    end

    def viaf_uri?(uri)
      url = uri.to_s
      url.match(/^http:\/\/viaf\.org\/viaf\/\d+$/).nil? ? false : true
    end

    def lcnaf_uri?(uri)
      url = uri.to_s
      url.match(/^http:\/\/id\.loc\.gov\/authorities\/names\/n[bors]{0,1}\d+$/).nil? ? false : true
    end

    private

    def creator_graph_and_viaf_uri(uri)
      # Convert the URI to an RDF::URI object if it is not already
      uri = convert_uri(uri)

      # 1. Get the VIAF data and determine the VIAF URI
      begin
        if lcnaf_uri?(uri)
          # Load the VIAF data graph and determine the VIAF URI based on the LCNAF URI.
          identifier = lcnaf_uri_to_identifier(uri)
          viaf_url   = "http://viaf.org/viaf/sourceID/" + URI.encode_www_form_component("LC|#{identifier}")
          viaf_graph = RDF::Graph.load(viaf_url, format: :rdfxml)
          viaf_uri   = viaf_graph.query({predicate: SCHEMA_SAME_AS, object: uri}).first.subject
        elsif viaf_uri?(uri)
          # Load the VIAF data graph using the URI
          viaf_uri   = uri
          viaf_graph = RDF::Graph.load(uri, format: :rdfxml)
        else
          raise BibCard::InvalidURIException
        end
      rescue IOError
        raise BibCard::EntityNotFoundException
      rescue Errno::ECONNRESET
        raise BibCard::CrawlException.new("Unable to access VIAF, connection reset by peer.")
      rescue NoMethodError => e
        undifferentiated_uri_msg = "This VIAF URI has been corrupted by an 'undifferentiate name' and should be treated as unusable."
        results = viaf_graph.query({predicate: RDFS_COMMENT, object: undifferentiated_uri_msg})
        if results.size > 0
          raise BibCard::EntityNotFoundException.new(undifferentiated_uri_msg)
        else
          raise e
        end
      end

      # 2. Crawl and use it as a basis for crawling the other data sources
      crawler = Crawler.new(viaf_uri, viaf_graph)
      graph = crawler.creator_graph
      [graph, viaf_uri]
    end

    def lcnaf_uri_to_identifier(uri)
      url = uri.to_s
      url.gsub("http://id.loc.gov/authorities/names/", "")
    end

    # Convert
    def convert_uri(uri)
      uri.is_a?(RDF::URI) ? uri : RDF::URI.new(uri)
    end
  end
end

# Rails support
require 'bib_card/railtie' if defined?(Rails)
