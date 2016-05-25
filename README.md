# BibCard

BibCard is a Ruby library for retrieving and assembling knowledge card information about the authors found in bibliographic data. It takes identifiers like Library of Congress Name Authority File (LCNAF) IDs or VIAF URIs as input and crawls Linked Open Data sources on the web to assemble a Ruby objects or RDF serializations. This library will fetch data from:

* [Virtual International Authority File (VIAF)](http://viaf.org/)
* [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page)
* [DBpedia](http://wiki.dbpedia.org/)
* [Getty Vocabularies LOD](http://vocab.getty.edu/)

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

```ruby
require 'bib_card'

lcnaf_id = "n78086005"
person = BibCard
````

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bib_card. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

