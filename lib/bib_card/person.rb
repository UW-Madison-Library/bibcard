module BibCard
  class Person < Spira::Base

    property :birth_date, predicate: SCHEMA_BIRTHDATE, type: XSD.string
    property :death_date, predicate: SCHEMA_DEATHDATE, type: XSD.string
    has_many :types, predicate: RDF.type, type: RDF::URI

    def uri
      self.subject
    end

    def name(preferred_languages = nil)
      if preferred_languages
        matches = Spira.repository.query({subject: @subject, predicate: SCHEMA_NAME}).reduce(Array.new) do |matches, stmt|
          language = stmt.object.language.to_s
          matches << stmt if preferred_languages.include?(language)
          matches
        end
      else
        matches = Spira.repository.query({subject: @subject, predicate: SCHEMA_NAME})
      end
      matches.first.nil? ? nil : matches.first.object.to_s
    end

    def loc_uri
      stmt = related_entity_by_uri_prefix("http://id.loc.gov/authorities/names/")
      stmt.nil? ? nil : stmt.object
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

    def dbpedia_resource
      self.dbpedia_uri.as(BibCard::DBPedia::Resource) if self.dbpedia_uri
    end

    def getty_subject
      self.getty_uri.as(BibCard::Getty::Subject) if self.getty_uri
    end

    def wikidata_entity
      self.wikidata_uri.as(BibCard::Wikidata::Entity) if self.wikidata_uri
    end

    protected

    def related_entity_by_uri_prefix(domain)
      Spira.repository.query({subject: @subject, predicate: SCHEMA_SAME_AS}).select {|s| s.object.to_s.match(domain)}.first
    end

  end
end
