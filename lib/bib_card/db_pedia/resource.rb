module BibCard
  module DBPedia
    class Resource < Spira::Base
    
      configure base_uri: "http://dbpedia.org/resource/"
    
      property :given_name, predicate: BibCard::FOAF_GIVEN_NAME, type: XSD.string
      property :surname, predicate: BibCard::FOAF_SURNAME, type: XSD.string
      property :rdfs_label, predicate: RDF::RDFS.label, type: XSD.string
      property :abstract, predicate: BibCard::DBO_ABSTRACT, type: XSD.string
      # property :founded, predicate: DBP_FOUNDED, type: XSD.string
      # property :location, predicate: DBP_LOCATION, type: XSD.string
      # has_many :influences, predicate: DBO_INFLUENCED_BY, type: 'DBPedia::Resource'
      # has_many :influencees, predicate: DBO_INFLUENCED, type: 'DBPedia::Resource'
    
      def name
        if self.given_name and self.surname
          self.given_name + ' ' + self.surname
        else
          self.rdfs_label
        end
      end
    
      def film_appearances
        Spira.repository.query(predicate: DBO_STARRING, object: self.subject).map do |film|
          film.subject.as(DBPedia::Resource)
        end
      end
    
    end
  end
end