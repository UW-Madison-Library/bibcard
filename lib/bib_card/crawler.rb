module BibCard
  class Crawler
    
    def initialize(uri, repository)
      @subject = RDF::URI(uri)
      @repository = repository
    end
  
    SPARQL_ENDPOINTS = {
      getty: "http://vocab.getty.edu/sparql?query=",
      wikidata: "http://query.wikidata.org/sparql?query=",
      dbpedia: "http://dbpedia.org/sparql?query="
    }

    def birth_date
      stmt = @repository.query(subject: @subject, predicate: SCHEMA_BIRTHDATE).first
      stmt.nil? ? nil : stmt.object
    end
    
    def death_date
      stmt = @repository.query(subject: @subject, predicate: SCHEMA_DEATHDATE).first
      stmt.nil? ? nil : stmt.object
    end
    
    def loc_uri
      stmt = @repository.query(subject: @subject, predicate: SCHEMA_SAME_AS).select {|s| s.object.to_s.match('http://id.loc.gov/authorities/names/')}.first
      stmt.nil? ? nil : stmt.object
    end
    
    def dbpedia_uri
      stmt = @repository.query(subject: @subject, predicate: SCHEMA_SAME_AS).select {|s| s.object.to_s.match('http://dbpedia.org/resource')}.first
      stmt.nil? ? nil : stmt.object
    end
    
    def getty_uri
      stmt = @repository.query(subject: @subject, predicate: SCHEMA_SAME_AS).select {|s| s.object.to_s.match('vocab.getty.edu')}.first
      stmt.nil? ? nil : RDF::URI.new( stmt.object.to_s.gsub('-agent', '') )
    end
    
    def wikidata_uri
      stmt = @repository.query(subject: @subject, predicate: SCHEMA_SAME_AS).select {|s| s.object.to_s.match('http://www.wikidata.org/entity')}.first
      stmt.nil? ? nil : stmt.object
    end
    
    def creator_graph
      graph = RDF::Graph.new
      if @repository.size > 0
        @repository.query(subject: @subject, predicate: RDF.type).each {|stmt| graph << stmt}
        @repository.query(subject: @subject, predicate: SCHEMA_NAME).each {|stmt| graph << stmt}
        graph << [@subject, SCHEMA_BIRTHDATE, self.birth_date] if self.birth_date
        graph << [@subject, SCHEMA_DEATHDATE, self.death_date] if self.death_date
        graph << [@subject, SCHEMA_SAME_AS, self.loc_uri] if self.loc_uri
        graph << [@subject, SCHEMA_SAME_AS, self.dbpedia_uri] if self.dbpedia_uri
        graph << [@subject, SCHEMA_SAME_AS, self.getty_uri] if self.getty_uri
        graph << [@subject, SCHEMA_SAME_AS, self.wikidata_uri] if self.wikidata_uri
        graph << dbpedia_graph if self.dbpedia_uri
        graph << getty_note_graph if self.getty_uri
        graph << wikidata_graph if self.wikidata_uri
      end
      graph
    end
    
    def dbpedia_graph
      graph = RDF::Graph.new
      begin
        graph << profile_graph
        graph << influence_graph
        graph << film_graph
      rescue RestClient::RequestTimeout
        BibCard.logger.warn "DBPedia failed to respond. SPARQL query request timed out after 5 seconds for #{@current_query}."
      rescue Exception => e
        BibCard.logger.warn "DBPedia failed to respond. SPARQL query request for #{@current_query}. Error: #{e.message}"
      end
      graph
    end
    
    def influence_graph
      graph = RDF::Graph.new
      [:influences, :influenced].each do |relationship|
        m = self.method(relationship)
        m.call.each do |influence|
          if relationship == :influences
            field = "influence"
            predicate = DBO_INFLUENCED_BY
          else
            field = "influenced"
            predicate = DBO_INFLUENCED
          end
          influence_entity = RDF::URI.new(influence[field]["value"])
          graph << [self.dbpedia_uri, predicate, influence_entity]
          graph << [influence_entity, FOAF_GIVEN_NAME, influence["#{field}GivenName"]["value"]]
          graph << [influence_entity, FOAF_SURNAME, influence["#{field}Surname"]["value"]]
          if influence["influenceSameAs"]
            graph << [influence_entity, RDF::OWL.sameAs, influence["#{field}SameAs"]["value"]]
          end
        end
      end
      graph
    end
    
    def film_graph
      @current_query = "film graph"
      graph = RDF::Graph.new
      self.film_appearances.each do |appearance|
        film = RDF::URI.new(appearance["film"]["value"])
        graph << [film, DBO_STARRING, self.dbpedia_uri]
        graph << [film, RDF::RDFS.label, appearance["filmName"]["value"]]
        graph << [film, DBO_ABSTRACT, appearance["filmAbstract"]["value"]]
      end
      graph
    end
    
    def profile_graph
      @current_query = "profile graph"
      graph = RDF::Graph.new
      dbpedia_subject = self.dbpedia_uri
      profile = self.dbpedia_profile
      if profile
        graph << [dbpedia_subject, DBO_ABSTRACT, profile["abstract"]["value"]] if profile["abstract"]
        graph << [dbpedia_subject, DBP_FOUNDED, profile["foundedDate"]["value"]] if profile["foundedDate"]
        graph << [dbpedia_subject, DBP_LOCATION, profile["location"]["value"]] if profile["location"]
        graph << [dbpedia_subject, DBO_THUMBNAIL, profile["thumbnail"]["value"]] if profile["thumbnail"]
        graph << [dbpedia_subject, FOAF_DEPICTION, profile["depiction"]["value"]] if profile["depiction"]
      end
      graph
    end

    def influences
      @current_query = "influences graph"
      sparql = "
      #{self.dbpedia_sparql_prefixes}
      
      SELECT DISTINCT ?influence ?influenceGivenName ?influenceSurname ?influenceSameAs
      WHERE {
        { 
          ?influence dbo:influenced <#{self.dbpedia_uri}> . 
        }
        UNION
        {
          <#{self.dbpedia_uri}> dbo:influencedBy ?influence .
        }
        ?influence foaf:givenName ?influenceGivenName .
        ?influence foaf:surname ?influenceSurname .
        OPTIONAL { 
          ?influence owl:sameAs ?influenceSameAs . 
          FILTER regex(STR(?influenceSameAs), \"viaf.org\").
        }
      }
      "
      get_data(sparql, :dbpedia)
    end
    
    def influenced
      @current_query = "influence upon graph"
      sparql = "
      #{self.dbpedia_sparql_prefixes}
      
      SELECT ?influenced ?influencedGivenName ?influencedSurname ?influencedSameAs
      WHERE {
        { 
          <#{self.dbpedia_uri}> dbo:influenced ?influenced . 
        }
        UNION
        {
          ?influenced dbo:influencedBy <#{self.dbpedia_uri}> .
        }
        ?influenced foaf:givenName ?influencedGivenName .
        ?influenced foaf:surname ?influencedSurname .
        OPTIONAL { 
          ?influenced owl:sameAs ?influencedSameAs . 
          FILTER regex(STR(?influencedSameAs), \"viaf.org\").
        }
      }
      "
      get_data(sparql, :dbpedia)
    end
    
    def dbpedia_profile
      sparql = "
      #{self.dbpedia_sparql_prefixes}
      
      SELECT ?abstract ?foundedDate ?location ?thumbnail ?depiction
      WHERE {
        OPTIONAL { <#{self.dbpedia_uri}> dbo:abstract ?abstract . }
        OPTIONAL {<#{self.dbpedia_uri}> dbp:location ?location . }
        OPTIONAL { <#{self.dbpedia_uri}> dbp:foundedDate ?foundedDate . }
        OPTIONAL { <#{self.dbpedia_uri}> dbo:thumbnail ?thumbnail . }
        OPTIONAL { <#{self.dbpedia_uri}> foaf:depiction ?depiction . }
        FILTER(langMatches(lang(?abstract), \"en\"))
      }
      "
      get_data(sparql, :dbpedia).first
    end
    
    def film_appearances
      sparql = "
      #{self.dbpedia_sparql_prefixes}
      
      SELECT ?film ?filmName ?filmAbstract
      WHERE {
        ?film dbo:starring <#{self.dbpedia_uri}> .
        ?film rdfs:label ?filmName .
        ?film dbo:abstract ?filmAbstract .
        FILTER(langMatches(lang(?filmName), \"en\"))
        FILTER(langMatches(lang(?filmAbstract), \"en\"))
      }
      "
      get_data(sparql, :dbpedia)
    end
  
    def getty_note_graph
      @current_query = "getty note graph"
      graph = RDF::Graph.new
      begin
        getty_subject = self.getty_uri
        self.getty_scope_notes.each do |scope_note|
          # Add the scope note itself
          scope_note_uri = RDF::URI.new(scope_note["scopeNote"]["value"])
          graph << [getty_subject, SKOS_SCOPE_NOTE, scope_note_uri]
          graph << [scope_note_uri, RDF.value, scope_note["scopeNoteValue"]["value"]]
        
          # Add the sources/citations for the scope note
          source_uri = RDF::URI.new(scope_note["source"]["value"])
          graph << [scope_note_uri, DC_SOURCE, source_uri]
          if scope_note["sourceShortTitle"]
            graph << [source_uri, BIBO_SHORT_TITLE, scope_note["sourceShortTitle"]["value"]]
          else
            parent_uri = RDF::URI.new(scope_note["parent"]["value"])
            graph << [source_uri, DC_IS_PART_OF, parent_uri]
            graph << [source_uri, RDF.type, BIBO_DOCUMENT_PART]
            graph << [parent_uri, BIBO_SHORT_TITLE, scope_note["parentShortTitle"]["value"]]
          end
        end
      rescue RestClient::RequestTimeout
        BibCard.logger.warn "Getty failed to respond. SPARQL query request timed out after 5 seconds for #{@current_query}."
      rescue Exception => e
        BibCard.logger.warn "Getty failed to respond. SPARQL query request for #{@current_query}. Error: #{e.message}"
      end
      graph
    end
  
    def getty_scope_notes
      sparql = "
      PREFIX ulan: <http://vocab.getty.edu/ulan/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX dct: <http://purl.org/dc/terms/>
      PREFIX bibo: <http://purl.org/ontology/bibo/>

      SELECT ?scopeNote ?scopeNoteValue ?source ?sourceShortTitle ?parent ?parentShortTitle
      WHERE {
        <#{self.getty_uri.to_s}> skos:scopeNote ?scopeNote .
        ?scopeNote rdf:value ?scopeNoteValue .
        ?scopeNote dct:source ?source .
        OPTIONAL { ?source bibo:shortTitle ?sourceShortTitle . }
        OPTIONAL {
          ?source dct:isPartOf ?parent .
          ?parent bibo:shortTitle ?parentShortTitle .
        }
      }
      "
      get_data(sparql, :getty)
    end
    
    def wikidata_graph
      graph = RDF::Graph.new
      begin
        wikidata_subject = self.wikidata_uri
        self.alma_maters.each do |alma_mater|
          @current_query = "alma maters graph"
          am_inst_uri   = RDF::URI.new(alma_mater["inst"]["value"])
          am_edu_stmt   = RDF::URI.new(alma_mater["statement"]["value"])
        
          graph << [wikidata_subject, WDT_EDUCATED_AT, am_inst_uri]
          graph << [am_inst_uri, RDF::RDFS.label, alma_mater["instLabel"]["value"]]
          graph << [wikidata_subject, WDP_EDUCATED_AT, am_edu_stmt]
          graph << [am_edu_stmt, WDPS_STMT_EDU_AT, am_inst_uri]
        
          # Not all assertions have references/citations
          if alma_mater["reference"]
            am_stmt_ref   = RDF::URI.new(alma_mater["reference"]["value"])
            am_ref_source = RDF::URI.new(alma_mater["source"]["value"])

            graph << [am_edu_stmt, PROV_DERIVED_FROM, am_stmt_ref]
            graph << [am_stmt_ref, WDR_STATED_IN, am_ref_source]
            graph << [am_ref_source, RDF::RDFS.label, alma_mater["sourceLabel"]["value"]]
          end
        end
      
        bio = self.brief_bio
        if bio
          @current_query = "brief bio graph"
          graph << [wikidata_subject, SCHEMA_DESCRIPTION, bio["description"]["value"]] if bio["description"]
          if bio["workLocation"]
            work_loc_uri = RDF::URI.new(bio["workLocation"]["value"])
            graph << [wikidata_subject, WDT_WORK_LOCATION, work_loc_uri]
            graph << [work_loc_uri, RDF::RDFS.label, bio["workLocationLabel"]["value"]]
          end
        end
      
        self.notable_works.each do |work|
          @current_query = "notable works graph"
          work_uri = RDF::URI.new(work["notableWork"]["value"])
          graph << [wikidata_subject, WDT_NOTABLE_WORKS, work_uri]
          graph << [work_uri, RDF::RDFS.label, work["notableWorkLabel"]["value"]]
          graph << [work_uri, WDT_ISBN, work["isbn"]["value"]] if work["isbn"]
          graph << [work_uri, WDT_OCLC_NUMBER, work["oclcNumber"]["value"]] if work["oclcNumber"]
        end
      rescue RestClient::RequestTimeout
        BibCard.logger.warn "WikiData failed to respond. SPARQL query request timed out after 5 seconds for #{@current_query}."
      rescue Exception => e
        BibCard.logger.warn "WikiData failed to respond. SPARQL query request for #{@current_query}. Error: #{e.message}"
      end
      graph
    end
    
    def alma_maters
      sparql = "
      #{self.wikidata_sparql_prefixes}

      SELECT DISTINCT ?inst ?instLabel ?statement ?reference ?source ?sourceLabel
      WHERE 
      {
        <#{self.wikidata_uri.to_s}> p:P69 ?statement .
        ?statement ps:P69 ?inst .
        OPTIONAL { 
          ?statement prov:wasDerivedFrom ?reference . 
          ?reference pref:P248 ?source .
          ?source rdfs:label ?sourceLabel .
          FILTER(langMatches(lang(?sourceLabel), \"en\"))
        }
        SERVICE wikibase:label {
          bd:serviceParam wikibase:language \"en\" .
        }
      }
      "
      get_data(sparql, :wikidata)
    end
    
    def brief_bio
      sparql = "
      #{self.wikidata_sparql_prefixes}
      
      SELECT DISTINCT ?description ?workLocation ?workLocationLabel
      WHERE 
      {
        <#{self.wikidata_uri.to_s}> schema:description ?description . 
        OPTIONAL {
          <#{self.wikidata_uri.to_s}> wdt:P937 ?workLocation .
        }
        SERVICE wikibase:label {
          bd:serviceParam wikibase:language \"en\" .
        }
        FILTER(langMatches(lang(?description), \"en\"))
      }
      "
      get_data(sparql, :wikidata).first
    end
    
    def notable_works
      sparql = "
      #{self.wikidata_sparql_prefixes}
      
      SELECT DISTINCT ?notableWork ?notableWorkLabel ?isbn ?oclcNumber
      WHERE 
      {
      	<#{self.wikidata_uri.to_s}> wdt:P800 ?notableWork .
        	OPTIONAL {
            ?notableWork wdt:P212 ?isbn .
            ?notableWork wdt:P243 ?oclcNumber .
          }
      	SERVICE wikibase:label {
      		bd:serviceParam wikibase:language \"en\" .
      	}
      }
      "
      notable_works = get_data(sparql, :wikidata)
      notable_works.select {|work| work["notableWorkLabel"] != nil and !work["notableWorkLabel"]["value"].match(/^Q\d+$/)}
    end
    
    protected
    
    def get_data(sparql, source)
      url = SPARQL_ENDPOINTS[source] + URI::encode(sparql.gsub(/\n/, ' '))
      data = RestClient::Request.execute(method: :get, url: url, headers: {accept: "application/sparql-results+json"}, timeout: 5)
      parsed_data = JSON.parse data
      parsed_data["results"]["bindings"]
    end
    
    def wikidata_sparql_prefixes
      "
      PREFIX wikibase: <http://wikiba.se/ontology#>
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX pref: <http://www.wikidata.org/prop/reference/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      "
    end
    
    def dbpedia_sparql_prefixes
      "
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX owl: <http://www.w3.org/2002/07/owl#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dbo: <http://dbpedia.org/ontology/>
      "
    end
    
  end
end
