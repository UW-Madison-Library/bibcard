module BibCard
  module Getty
    class Subject < Spira::Base
  
      configure base_uri: "http://vocab.getty.edu/ulan/"
  
      property :scope_note, predicate: SKOS_SCOPE_NOTE, type: 'ScopeNote'
  
    end
  end
end