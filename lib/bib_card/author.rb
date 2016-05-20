module BibCard
  class Author
    
    attr_accessor :uri
    
    def initialize(viaf_url, lc_uri)
      @graph = RDF::Graph.load(URI.encode(viaf_url), format: :rdfxml)
      @uri = @graph.query(predicate: SCHEMA_SAME_AS, object: RDF::URI.new(lc_uri)).first.subject
    end
    
  end
end