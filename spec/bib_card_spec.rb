require 'spec_helper'

describe BibCard do
  context "when loading a person" do
    before(:all) do
      @config = sparql_config
    end
    
    context "and the URI is an LCNAF URI" do
      before(:all) do
        stub_sparql_queries(@config, "picasso")
        @uri = "http://id.loc.gov/authorities/names/n78086005"
        
        @person_from_string = BibCard.person(@uri)
        @person_from_uri = BibCard.person(RDF::URI.new(@uri))
        @data_from_string = BibCard.person_data(@uri)
        @data_from_uri = BibCard.person_data(RDF::URI.new(@uri))
      end

      it "constructs a person when the URI is a String" do
        expect(@person_from_string).to be_a(BibCard::Person)
      end

      it "constructs a person when the URI is an RDF::URI" do
        expect(@person_from_uri).to be_a(BibCard::Person)
      end

      it "returns RDF triples when the URI is a String" do
        expect(@data_from_string).to be_a(String)
      end
      
      it "returns RDF triples when the URI is a String that can be parsed" do
        parsed_triples = read_ntriples(@data_from_string)
        expect(parsed_triples.size).to eq(195)
      end

      it "returns RDF triples when the URI is an RDF::URI" do
        expect(@data_from_uri).to be_a(String)
      end

      it "returns RDF triples when the URI is an RDF::URI that can be parsed" do
        parsed_triples = read_ntriples(@data_from_uri)
        expect(parsed_triples.size).to eq(195)
      end
    end

    context "and the URI is a VIAF URI" do
      before(:all) do
        stub_sparql_queries(@config, "picasso")
        @uri = "http://viaf.org/viaf/15873"
        
        @person_from_string = BibCard.person(@uri)
        @person_from_uri = BibCard.person(RDF::URI.new(@uri))
        @data_from_string = BibCard.person_data(@uri)
        @data_from_uri = BibCard.person_data(RDF::URI.new(@uri))
      end

      it "constructs a person when the URI is a String" do
        expect(@person_from_string).to be_a(BibCard::Person)
      end

      it "constructs a person when the URI is an RDF::URI" do
        expect(@person_from_uri).to be_a(BibCard::Person)
      end

      it "returns RDF triples when the URI is a String" do
        expect(@data_from_string).to be_a(String)
      end
      
      it "returns RDF triples when the URI is a String that can be parsed" do
        parsed_triples = read_ntriples(@data_from_string)
        expect(parsed_triples.size).to eq(195)
      end

      it "returns RDF triples when the URI is an RDF::URI" do
        expect(@data_from_uri).to be_a(String)
      end

      it "returns RDF triples when the URI is an RDF::URI that can be parsed" do
        parsed_triples = read_ntriples(@data_from_uri)
        expect(parsed_triples.size).to eq(195)
      end
    end
  end
end
