module BibCard
  module Getty
    class Source < Spira::Base
  
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :short_title, predicate: BIBO_SHORT_TITLE, type: XSD.string 
  
      def parent
        stmt = Spira.repository.query(subject: self.subject, predicate: DC_IS_PART_OF).first
        stmt.nil? ? nil : stmt.object.as(Source)
      end
  
    end
  end
end