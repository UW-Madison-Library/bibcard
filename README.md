# BibCard

BibCard is a Ruby library for retrieving and assembling knowledge card information about the authors found in bibliographic data. It takes identifiers like Library of Congress Name Authority File (LCNAF) or VIAF URIs as input and crawls Linked Open Data sources on the web to assemble a Ruby objects or RDF serializations. This library will fetch data from:

* [Virtual International Authority File (VIAF)](http://viaf.org/)
* [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page)
* [DBpedia](http://wiki.dbpedia.org/)
* [Getty Vocabularies LOD](http://vocab.getty.edu/)

The VIAF URI lies at the core of the `BibCard::Person` object because it acts as a hub to many other data sources on the Web. With the VIAF data in hand the other three sources listed above are "crawled" for more information about a given identity. Technically the data is requested by making one or more HTTP requests to each of the data sources' public SPARQL endpoints.

`BibCard` makes extensive use of the [Spira](https://github.com/ruby-rdf/spira) library for RDF-to-object mapping. The result is that after assembling a micrograph of knowledge card data the client can work with simple code objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bib_card'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bib_card

## Usage

### Instantiate a `BibCard::Person`

Given a Library of Congress Name Authority File or VIAF URI, instantiate a `BibCard::Person` and inspect the data.

*Note:* Every call to to `BibCard.person()` will make many calls to the public SPARQL endpoints for the sources cited above.

```ruby
require 'bib_card'

lcnaf_uri = "http://id.loc.gov/authorities/names/n78086005"
person = BibCard.person(lcnaf_uri)

person.english_name # => "Pablo Picasso"
person.birth_date   # => "1881-10-25"
person.death_date   # => "1973-04-09"

person.dbpedia_resource          # => <BibCard::DBPedia::Resource:70307318111440 @subject: http://dbpedia.org/resource/Pablo_Picasso>
person.dbpedia_resource.abstract # => "Pablo Ruiz y Picasso, also known as Pablo Picasso (/pɪˈkɑːsoʊ, -ˈkæsoʊ/; Spanish: [ˈpaβlo piˈkaso]; 25 October 1881 – 8 April 1973), was a Spanish painter..."

person.getty_subject                                                      # => <BibCard::Getty::Subject:70307331508400 @subject: http://vocab.getty.edu/ulan/500009666>
person.getty_subject.scope_note                                           # => <BibCard::Getty::ScopeNote:70307331409520 @subject: http://vocab.getty.edu/ulan/scopeNote/53649>
person.getty_subject.scope_note.value                                     # => "Long-lived and very influential Spanish artist, active in France. He dominated 20th-century European art. With Georges Braque, he is credited with inventing Cubism."
person.getty_subject.scope_note.sources                                   # => [<BibCard::Getty::Source:70307327167300 @subject: http://vocab.getty.edu/ulan/source/2100153925>, <BibCard::Getty::Source:70307327106100 @subject: http://vocab.getty.edu/ulan/source/2100156698>]
person.getty_subject.scope_note.sources.map {|source| source.short_title} # => ["LCNAF Library of Congress Name Authority File  [n.d.]", "Grove Dictionary of Art online (1999-2002)"]
```

### Fetch Raw Data for a `BibCard::Person`

A BibCard knowledge/info card is generated from many different sources, which is inherently slow. You can also retrieve person data as a serialized string of RDF n-triples. The raw data is available so that it can be cached locally. Once the data is cached you can load a [Spira](https://github.com/ruby-rdf/spira) repository and instantiate a `BibCard::Person` object.

```ruby
require 'bib_card'

lcnaf_uri = "http://id.loc.gov/authorities/names/n78086005"
data = BibCard.person_data(lcnaf_uri)
puts data

# <http://viaf.org/viaf/15873> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person> .
# <http://viaf.org/viaf/15873> <http://schema.org/deathDate> "1973-04-09" .
# <http://viaf.org/viaf/15873> <http://schema.org/sameAs> <http://id.loc.gov/authorities/names/n78086005> .
# ...

#### cache the serialized data ####

Spira.repository = RDF::Repository.new.from_ntriples(data)
viaf_uri         = Spira.repository.query(predicate: BibCard::SCHEMA_SAME_AS, object: RDF::URI.new(lcnaf_uri)).first.subject
person           = viaf_uri.as(BibCard::Person)

person              # => <BibCard::Person:70307327106900 @subject: http://viaf.org/viaf/15873>
person.english_name # => "Pablo Picasso"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bib_card. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

