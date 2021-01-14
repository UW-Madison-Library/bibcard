module BibCard
  module Getty
    class ScopeNote < Spira::Base

      configure base_uri: "http://vocab.getty.edu/ulan/scopeNote/"

      property :value, predicate: RDF.value, type: XSD.string

      def sources
        Spira.repository.query({subject: self.subject, predicate: DC_SOURCE}).map do |stmt|
          source = stmt.object.as(Source)
          source.type == BIBO_DOCUMENT_PART ? source.parent : source
        end
      end

    end
  end
end
