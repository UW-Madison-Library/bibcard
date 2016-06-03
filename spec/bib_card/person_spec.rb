describe BibCard::Person do 
  context "a person loaded by URI" do
    before(:all) do
      @person = person("stein")
    end
    
    it "has a URI" do
      expect(@person.uri).to eq(RDF::URI.new("http://viaf.org/viaf/22149082"))
    end
    
    it "has a type" do
      expect(@person.types).to include(RDF::URI.new("http://schema.org/Person"))
    end
    
    it "is a person" do
      expect(@person).to be_a(BibCard::Person)
    end
    
    it "has a type" do
      expect(@person.types).to include(RDF::URI.new("http://schema.org/Person"))
    end
    
    it "has a name" do
      expect(@person.name).to be_a(String)
    end
    
    it "has an English name" do
      expect(@person.name(["en-us", "en"])).to eq("Gertrude Stein")
    end
    
    it "gracefully handles a name for a language with no matches" do
      expect(@person.name(["xx-zz"])).to be_nil
    end
    
    it "has a birth date" do
      expect(@person.birth_date).to eq("1874-02-03")
    end
    
    it "has a death date" do
      expect(@person.death_date).to eq("1946-07-27")
    end
    
    it "matches an LCNAF personal name" do
      expect(@person.loc_uri).to eq(RDF::URI.new("http://id.loc.gov/authorities/names/n79006977"))
    end
    
    it "matches a Getty identity" do
      expect(@person.getty_uri).to eq(RDF::URI.new("http://vocab.getty.edu/ulan/500273319"))
    end
    
    it "matches a DBPedia resource" do
      expect(@person.dbpedia_uri).to eq(RDF::URI.new("http://dbpedia.org/resource/Gertrude_Stein"))
    end
    
    it "matches a Wikidata entity" do
      expect(@person.wikidata_uri).to eq(RDF::URI.new("http://www.wikidata.org/entity/Q188385"))
    end
    
    it "has a dbpedia abstract" do
      abstract = "Gertrude Stein (February 3, 1874 \u2013 July 27, 1946) was an American writer of novels, poetry and plays. Born in the Allegheny West neighborhood of Pittsburgh, Pennsylvania, and raised in Oakland, California, Stein moved to Paris in 1903, making France her home for the remainder of her life. A literary innovator and pioneer of Modernist literature, Stein\u2019s work broke with the narrative, linear, and temporal conventions of the 19th-century. She was also known as a collector of Modernist art.In 1933, Stein published a kind of memoir of her Paris years, The Autobiography of Alice B. Toklas, written in the voice of Toklas, her life partner. The book became a literary bestseller and vaulted Stein from the relative obscurity of cult literary figure into the light of mainstream attention."
      expect(@person.dbpedia_resource.abstract).to eq(abstract)
    end
  end
  
  context "a person with an influence network" do
    before(:all) do
      @person = person("picasso")
    end
    
    it "has the right number of influences" do
      expect(@person.dbpedia_resource.influences.size).to eq(2)
    end
    
    it "has influences with names" do
      influence_names = @person.dbpedia_resource.influences.map {|resource| "#{resource.given_name} #{resource.surname}"}.sort
      expect(influence_names).to eq(["Paul Cezanne", "Stanley William Hayter"])
    end
    
    it "has the right number of people influenced" do
      expect(@person.dbpedia_resource.influencees.size).to eq(53)
    end
    
    it "has influences with names" do
      influencee_names = @person.dbpedia_resource.influencees.map {|resource| "#{resource.given_name} #{resource.surname}"}.sort
      expect(influencee_names).to include("Georges Braque")
    end
  end
  
  context "a person with a getty scope note" do
    before(:all) do
      @person = person("picasso")
    end
    
    it "has a scope note value" do
      scope_note = "Long-lived and very influential Spanish artist, active in France. He dominated 20th-century European art. With Georges Braque, he is credited with inventing Cubism."
      expect(@person.getty_subject.scope_note.value).to eq(scope_note)
    end
    
    it "has scope note sources" do
      expected = "Grove Dictionary of Art online (1999-2002); LCNAF Library of Congress Name Authority File  [n.d.]"
      actual = @person.getty_subject.scope_note.sources.map {|source| source.short_title}.sort.join("; ")
      expect(actual).to eq(expected)
    end
  end
  
  context "a person with a Wikidata entity" do
    before(:all) do
      @person = person("picasso")
    end
    
    it "has a description" do
      description = "Spanish painter, sculptor, printmaker, ceramicist, and stage designer"
      expect(@person.wikidata_entity.description).to eq(description)
    end
    
    it "has a work location" do
      expect(@person.wikidata_entity.work_location.name).to eq("Paris")
    end
    
    it "has alma maters" do
      expect(@person.wikidata_entity.alma_maters.size).to eq(1)
      expect(@person.wikidata_entity.alma_maters.first.name).to eq("Real Academia de Bellas Artes de San Fernando")
    end
    
    it "has notable works" do
      notable_work_names = @person.wikidata_entity.notable_works.map {|work| work.name}.sort
      expect(notable_work_names).to eq(["Guernica", "Les Demoiselles d'Avignon"])
    end
  end
  
  context "a person with alma maters" do
    before(:all) do
      @person = person("stein")
    end
    
    it "can have source citations" do
      school_with_source = @person.wikidata_entity.alma_maters.select {|school| school.name == "Radcliffe College"}.first
      expect(school_with_source.source.name).to eq("The Feminist Companion to Literature in English")
    end
  end
  
  context "a person with film appearances" do
    before(:all) do
      @person = person("pollan")
    end
    
    it "has films" do
      expected = ["Cowspiracy", "Food, Inc.", "Fresh (2009 film)", "King Corn (film)"]
      actual = @person.dbpedia_resource.film_appearances.map {|appearance| appearance.name}.sort
      expect(actual).to eq(expected)
    end
  end
end