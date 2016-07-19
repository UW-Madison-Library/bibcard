module BibCard
  # SHOULD BE LOADED VIA RDF::Vocab, but not working
  FOAF_GIVEN_NAME     = RDF::URI.new('http://xmlns.com/foaf/0.1/givenName')
  FOAF_SURNAME        = RDF::URI.new('http://xmlns.com/foaf/0.1/surname')
  FOAF_DEPICTION      = RDF::URI.new('http://xmlns.com/foaf/0.1/depiction')
  SKOS_SCOPE_NOTE     = RDF::URI.new('http://www.w3.org/2004/02/skos/core#scopeNote')
  DC_SOURCE           = RDF::URI.new('http://purl.org/dc/terms/source')
  DC_IS_PART_OF       = RDF::URI.new('http://purl.org/dc/terms/isPartOf')

  SCHEMA_PERSON       = RDF::URI.new('http://schema.org/Person')
  SCHEMA_ORGANIZATION = RDF::URI.new('http://schema.org/Organization')
  SCHEMA_SAME_AS      = RDF::URI.new('http://schema.org/sameAs')
  SCHEMA_NAME         = RDF::URI.new('http://schema.org/name')
  SCHEMA_BIRTHDATE    = RDF::URI.new('http://schema.org/birthDate')
  SCHEMA_DEATHDATE    = RDF::URI.new('http://schema.org/deathDate')
  SCHEMA_DESCRIPTION  = RDF::URI.new('http://schema.org/description')
  SCOPE_NOTE          = RDF::URI.new('http://vocab.getty.edu/ontology#ScopeNote')
  SKOS_NOTE           = RDF::URI.new('http://www.w3.org/2004/02/skos/core#note')
  SKOS_SCOPENOTE      = RDF::URI.new('http://www.w3.org/2004/02/skos/core#scopeNote')
  DCT_SOURCE          = RDF::URI.new('http://purl.org/dc/terms/source')
  DCT_IS_PART_OF      = RDF::URI.new('http://purl.org/dc/terms/isPartOf')
  BIBO_DOCUMENT_PART  = RDF::URI.new('http://purl.org/ontology/bibo/DocumentPart')
  BIBO_SHORT_TITLE    = RDF::URI.new('http://purl.org/ontology/bibo/shortTitle')
  WDT_WORK_LOCATION   = RDF::URI.new('http://www.wikidata.org/prop/direct/P937')
  WDT_NOTABLE_WORKS   = RDF::URI.new('http://www.wikidata.org/prop/direct/P800')
  WDT_ISBN            = RDF::URI.new('http://www.wikidata.org/prop/direct/P212')
  WDT_OCLC_NUMBER     = RDF::URI.new('http://www.wikidata.org/prop/direct/P243')
  WDT_EDUCATED_AT     = RDF::URI.new('http://www.wikidata.org/prop/direct/P69')
  WDP_EDUCATED_AT     = RDF::URI.new('http://www.wikidata.org/prop/P69')
  WDPS_STMT_EDU_AT    = RDF::URI.new('http://www.wikidata.org/prop/statement/P69')
  PROV_DERIVED_FROM   = RDF::URI.new('http://www.w3.org/ns/prov#wasDerivedFrom')
  WDR_STATED_IN       = RDF::URI.new('http://www.wikidata.org/prop/reference/P248')
  DBO_INFLUENCED_BY   = RDF::URI.new('http://dbpedia.org/ontology/influencedBy')
  DBO_INFLUENCED      = RDF::URI.new('http://dbpedia.org/ontology/influenced')
  DBO_STARRING        = RDF::URI.new('http://dbpedia.org/ontology/starring')
  DBO_ABSTRACT        = RDF::URI.new('http://dbpedia.org/ontology/abstract')
  DBO_THUMBNAIL       = RDF::URI.new('http://dbpedia.org/ontology/thumbnail')
  DBP_FOUNDED         = RDF::URI.new('http://dbpedia.org/ontology/foundedDate')
  DBP_LOCATION        = RDF::URI.new('http://dbpedia.org/ontology/location')

  VOCAB_PREFIXES = {
    schema: RDF::URI.new("http://schema.org/"),
    foaf: RDF::URI.new("http://xmlns.com/foaf/0.1/"), 
    owl: RDF::URI.new("http://www.w3.org/2002/07/owl#"), 
    skos: RDF::URI.new("http://www.w3.org/2004/02/skos/core#"), 
    dcterms: RDF::URI.new("http://purl.org/dc/terms/"), 
    bibo: RDF::URI.new("http://purl.org/ontology/bibo/"), 
    wdpd: RDF::URI.new("http://www.wikidata.org/prop/direct/"), 
    wdpr: RDF::URI.new("http://www.wikidata.org/prop/reference/"),
    wdps: RDF::URI.new("http://www.wikidata.org/prop/statement/"),
    wdp: RDF::URI.new("http://www.wikidata.org/prop/"),
    rdfs: RDF::URI.new("http://www.w3.org/2000/01/rdf-schema#"),
    dbo: RDF::URI.new("http://dbpedia.org/ontology/"),
    rdf: RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
  }

  JSON_LD_CONTEXT = {
    schema: "http://schema.org/",
    foaf: "http://xmlns.com/foaf/0.1/", 
    owl: "http://www.w3.org/2002/07/owl#", 
    skos: "http://www.w3.org/2004/02/skos/core#", 
    dcterms: "http://purl.org/dc/terms/", 
    bibo: "http://purl.org/ontology/bibo/", 
    wdpd: "http://www.wikidata.org/prop/direct/", 
    wdp: "http://www.wikidata.org/prop/", 
    rdfs: "http://www.w3.org/2000/01/rdf-schema#",
    dbo: "http://dbpedia.org/ontology/",
    rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  }

  JSON_LD_FRAME = {
    "@context" => JSON_LD_CONTEXT,
    "@type" => ["schema:Person", "schema:Organization"]
  }
end