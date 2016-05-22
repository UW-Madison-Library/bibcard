module BibCard
  module Wikidata
    class Entity < Spira::Base
    
      configure base_uri: "http://www.wikidata.org/entity/"
    
      property :schema_name, predicate: SCHEMA_NAME, localized: true
      property :rdfs_label, predicate: RDF::RDFS.label, type: XSD.string
      property :description, predicate: SCHEMA_DESCRIPTION, type: XSD.string
      property :work_location, predicate: WDT_WORK_LOCATION, type: 'Wikidata::Entity'
      has_many :alma_maters, predicate: WDT_EDUCATED_AT, type: 'Wikidata::Entity'
      has_many :notable_works, predicate: WDT_NOTABLE_WORKS, type: 'Wikidata::Entity'
    
      def name
        self.schema_name.nil? ? self.rdfs_label : self.schema_name
      end
    
      def source
        edu_assertion = Spira.repository.query(predicate: WDPS_STMT_EDU_AT, object: self.subject).first.subject
        reference_stmt = Spira.repository.query(subject: edu_assertion, predicate: PROV_DERIVED_FROM).first if edu_assertion
        reference = reference_stmt.object if reference_stmt
        source = Spira.repository.query(subject: reference, predicate: WDR_STATED_IN).first.object if reference
        source.nil? ? nil : source.as(Wikidata::Entity)
      end
    
    end
  end
end