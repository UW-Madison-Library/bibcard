describe BibCard::Person do 
  context "when loading an personal name authority from a VIAF URL/LC URI commbination" do
    before(:each) do
      viaf_url = "http://viaf.org/viaf/sourceID/LC|n79006977"
      lc_uri   = "http://id.loc.gov/authorities/names/n79006977"
      stub_request(:get, viaf_url).to_return(body: body_content("viaf/LC-n79006977.xml"), :status => 200)
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
  end
end