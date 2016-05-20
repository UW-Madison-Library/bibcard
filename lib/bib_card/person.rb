module BibCard
  class Person < Spira::Base
    
    property :birth_date, predicate: SCHEMA_BIRTH_DATE, type: XSD.string
    property :death_date, predicate: SCHEMA_DEATH_DATE, type: XSD.string
    has_many :types, predicate: RDF.type, type: RDF::URI
    
    def uri
      self.subject
    end
    
    def english_name
      english_value(SCHEMA_NAME).to_s
    end
    
    def dbpedia_uri
      stmt = related_entity_by_uri_prefix("http://dbpedia.org/resource")
      stmt.nil? ? nil : stmt.object
    end
    
    def getty_uri
      stmt = related_entity_by_uri_prefix("http://vocab.getty.edu/ulan")
      # Note that we are modifying the URI to get the RWO URI
      stmt.nil? ? nil : RDF::URI.new( stmt.object.to_s.gsub('-agent', '') )
    end
    
    def wikidata_uri
      stmt = related_entity_by_uri_prefix("http://www.wikidata.org/entity")
      stmt.nil? ? nil : stmt.object
    end
    
    protected
    
    def related_entity_by_uri_prefix(domain)
      Spira.repository.query(subject: @subject, predicate: SCHEMA_SAME_AS).select {|s| s.object.to_s.match(domain)}.first
    end
    
    def english_value(predicate)
      english_names = Spira.repository.query(subject: @subject, predicate: predicate).select do |stmt|
        stmt.object.language.to_s == "en-US" or stmt.object.language.to_s.start_with?("en")
      end
      if english_names.first
        english_names.first.object 
      else
        Spira.repository.query(subject: @subject, predicate: predicate).first.object
      end
    end
    
  end
end