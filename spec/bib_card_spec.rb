require 'spec_helper'

describe BibCard do
  context "when parsing URIs" do
    it "detects a LCNAF URI with the prefix 'n'" do
      uri = "http://id.loc.gov/authorities/names/n123456"
      expect(BibCard.lcnaf_uri?(uri)).to be true
    end

    it "detects a LCNAF URI with the prefix 'no'" do
      uri = "http://id.loc.gov/authorities/names/no123456"
      expect(BibCard.lcnaf_uri?(uri)).to be true
    end

    it "detects a LCNAF URI with the prefix 'nr'" do
      uri = "http://id.loc.gov/authorities/names/nr88009360"
      expect(BibCard.lcnaf_uri?(uri)).to be true
    end

    it "detects a LCNAF URI with the prefix 'nb'" do
      uri = "http://id.loc.gov/authorities/names/nb88009360"
      expect(BibCard.lcnaf_uri?(uri)).to be true
    end

    it "detects a LCNAF URI with the prefix 'ns'" do
      uri = "http://id.loc.gov/authorities/names/ns88009360"
      expect(BibCard.lcnaf_uri?(uri)).to be true
    end
  end

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
        expect(parsed_triples.size).to eq(283)
      end

      it "returns RDF triples when the URI is an RDF::URI" do
        expect(@data_from_uri).to be_a(String)
      end

      it "returns RDF triples when the URI is an RDF::URI that can be parsed" do
        parsed_triples = read_ntriples(@data_from_uri)
        expect(parsed_triples.size).to eq(283)
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
        expect(parsed_triples.size).to eq(283)
      end

      it "returns RDF triples when the URI is an RDF::URI" do
        expect(@data_from_uri).to be_a(String)
      end

      it "returns RDF triples when the URI is an RDF::URI that can be parsed" do
        parsed_triples = read_ntriples(@data_from_uri)
        expect(parsed_triples.size).to eq(283)
      end
    end
  end

  context "when encountering bad URIs for instantiation" do
    before(:all) do
      @config = sparql_config
      @unknown_uri_msg = "Invalid URI. BibCard requires a valid VIAF or LCNAF URI."
      @entity_not_found_msg = "Entity not found."
    end

    it "detects an incomplete VIAF URI" do
      uri = "http://viaf.org/viaf/"
      expect { BibCard.person(uri) }.to raise_error(BibCard::InvalidURIException, @unknown_uri_msg)
      expect { BibCard.person_data(uri) }.to raise_error(BibCard::InvalidURIException, @unknown_uri_msg)
    end

    it "detects an incomplete LCNAF URI" do
      uri = "http://id.loc.gov/authorities/names/"
      expect { BibCard.person(uri) }.to raise_error(BibCard::InvalidURIException, @unknown_uri_msg)
      expect { BibCard.person_data(uri) }.to raise_error(BibCard::InvalidURIException, @unknown_uri_msg)
    end

    it "detects a random URI" do
      uri = "http://library.wisc.edu"
      expect { BibCard.person(uri) }.to raise_error(BibCard::InvalidURIException, @unknown_uri_msg)
      expect { BibCard.person_data(uri) }.to raise_error(BibCard::InvalidURIException, @unknown_uri_msg)
    end

    it "detects a VIAF URI for an entity that doesn't exist" do
      uri = "http://viaf.org/viaf/12345678901234567890"
      stub_request(:get, uri).to_return(status: 404)
      expect { BibCard.person(uri) }.to raise_error(BibCard::EntityNotFoundException, @entity_not_found_msg)
    end

    it "detects a LCNAF URI for an entity that doesn't exist" do
      uri = "http://id.loc.gov/authorities/names/no1234567890123456789"
      stub_request(:get, "http://viaf.org/viaf/sourceID/LC%7Cno1234567890123456789").to_return(status: 404)
      expect { BibCard.person(uri) }.to raise_error(BibCard::EntityNotFoundException, @entity_not_found_msg)
    end

    it "detects an undifferentiated URI in VIAF" do
      stub_request(:get, @config["newton"]["viaf_lcnaf_url"]).to_return(body: body_content("viaf/LC-#{@config["newton"]["lcnaf_id"]}.xml"), :status => 200)
      uri = "http://id.loc.gov/authorities/names/#{@config["newton"]["lcnaf_id"]}"
      undifferentiated_uri_msg = "This VIAF URI has been corrupted by an 'undifferentiate name' and should be treated as unusable."
      expect { BibCard.person(uri) }.to raise_error(BibCard::EntityNotFoundException, undifferentiated_uri_msg)
    end
  end
end
