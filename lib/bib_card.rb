require "openssl"
require "rdf"
require "rdf/rdfxml"
require "spira"

require "bib_card/version"
require "bib_card/uris"
require "bib_card/author"
require "bib_card/person"

module BibCard

  # Note that this is a less than ideal way to instantiate a BibCard::Person object.
  # At the time of writing the Alma vendor platform returns author objects in the following format:
  #
  #   {
  #     "@id":"http://id.loc.gov/authorities/names/n79032058",
  #     "label":"Wittgenstein, Ludwig, 1889-1951.",
  #     "sameAs":"http://viaf.org/viaf/sourceID/LC|n79032058"
  #   }
  #
  # Ultimately what we want is the VIAF URI and this is the best hack for resolving from the LC URI 
  # and VIAF URL to the VIAF URI like http://viaf.org/viaf/24609378
  def self.author_from_viaf_lc(viaf_url, lc_uri)
    Spira.repository = RDF::Repository.load(URI.encode(viaf_url), format: :rdfxml)
    viaf_uri = Spira.repository.query(predicate: SCHEMA_SAME_AS, object: RDF::URI.new(lc_uri)).first.subject
    viaf_uri.as(Person)
  end

end
