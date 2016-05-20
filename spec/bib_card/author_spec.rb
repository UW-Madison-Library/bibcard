describe BibCard::Author do 
  context "when loading an author from a VIAF URI" do
    before(:each) do
      viaf_url = "http://viaf.org/viaf/sourceID/LC|n79006977"
      lc_uri   = "http://id.loc.gov/authorities/names/n79006977"
      stub_request(:get, viaf_url).to_return(body: body_content("viaf/LC-n79006977.xml"), :status => 200)
      @author = BibCard::Author.new(viaf_url, lc_uri)
    end
    
    it "has a URI" do
      expect(@author.uri).to eq(RDF::URI.new("http://viaf.org/viaf/22149082"))
    end
    
    it "has a type"
    it "has a first name"
    it "has a last name"
    it "has a birth date"
    it "has a death date"
    it "matches a Getty identity"
    it "matches a DBPedia resource"
    it "matches a Wikidata entity"
  end
end