describe BibCard::Person do 
  context "when loading a personal name authority from a VIAF URL/LC URI commbination" do
    before(:each) do
      viaf_url = "http://viaf.org/viaf/sourceID/LC|n79006977"
      lc_uri   = "http://id.loc.gov/authorities/names/n79006977"
      stub_request(:get, viaf_url).to_return(body: body_content("viaf/LC-n79006977.xml"), :status => 200)
      
      dbpedia_profile_url = "http://dbpedia.org/sparql?query=%20%20%20%20%20%20%20%20%20%20%20%20%20%20PREFIX%20rdfs:%20%3Chttp://www.w3.org/2000/01/rdf-schema%23%3E%20%20%20%20%20%20%20PREFIX%20owl:%20%3Chttp://www.w3.org/2002/07/owl%23%3E%20%20%20%20%20%20%20PREFIX%20foaf:%20%3Chttp://xmlns.com/foaf/0.1/%3E%20%20%20%20%20%20%20PREFIX%20dbo:%20%3Chttp://dbpedia.org/ontology/%3E%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20SELECT%20?abstract%20?foundedDate%20?location%20%20%20%20%20%20%20WHERE%20%7B%20%20%20%20%20%20%20%20%20OPTIONAL%20%7B%20%3Chttp://dbpedia.org/resource/Gertrude_Stein%3E%20dbo:abstract%20?abstract%20.%20%7D%20%20%20%20%20%20%20%20%20OPTIONAL%20%7B%3Chttp://dbpedia.org/resource/Gertrude_Stein%3E%20dbp:location%20?location%20.%20%7D%20%20%20%20%20%20%20%20%20OPTIONAL%20%7B%20%3Chttp://dbpedia.org/resource/Gertrude_Stein%3E%20dbp:foundedDate%20?foundedDate%20.%20%7D%20%20%20%20%20%20%20%20%20FILTER(langMatches(lang(?abstract),%20%22en%22))%20%20%20%20%20%20%20%7D%20%20%20%20%20%20%20"
      stub_request(:get, dbpedia_profile_url).to_return(body: body_content("dbpedia/profile.json"), :status => 200)
      @author = BibCard.author_from_viaf_lc(viaf_url, lc_uri)
    end
    
    it "has a URI" do
      expect(@author.uri).to eq(RDF::URI.new("http://viaf.org/viaf/22149082"))
    end
    
    it "is a person" do
      expect(@author).to be_a(BibCard::Person)
    end
    
    it "has a type" do
      expect(@author.types).to include(RDF::URI.new("http://schema.org/Person"))
    end
    
    it "has a English name" do
      expect(@author.english_name).to eq("Gertrude Stein")
    end
    
    it "has a birth date" do
      expect(@author.birth_date).to eq("1874-02-03")
    end
    
    it "has a death date" do
      expect(@author.death_date).to eq("1946-07-27")
    end
    
    it "matches a Getty identity" do
      expect(@author.getty_uri).to eq(RDF::URI.new("http://vocab.getty.edu/ulan/500273319"))
    end
    
    it "matches a DBPedia resource" do
      expect(@author.dbpedia_uri).to eq(RDF::URI.new("http://dbpedia.org/resource/Gertrude_Stein"))
    end
    
    it "matches a Wikidata entity" do
      expect(@author.wikidata_uri).to eq(RDF::URI.new("http://www.wikidata.org/entity/Q188385"))
    end
    
    it "has a dbpedia abstract" do
      abstract = "Gertrude Stein (February 3, 1874 \u2013 July 27, 1946) was an American writer of novels, poetry and plays. Born in the Allegheny West neighborhood of Pittsburgh, Pennsylvania, and raised in Oakland, California, Stein moved to Paris in 1903, making France her home for the remainder of her life. A literary innovator and pioneer of Modernist literature, Stein\u2019s work broke with the narrative, linear, and temporal conventions of the 19th-century. She was also known as a collector of Modernist art.In 1933, Stein published a kind of memoir of her Paris years, The Autobiography of Alice B. Toklas, written in the voice of Toklas, her life partner. The book became a literary bestseller and vaulted Stein from the relative obscurity of cult literary figure into the light of mainstream attention."
      expect(@author.dbpedia_resource.abstract).to eq(abstract)
    end
  end
end