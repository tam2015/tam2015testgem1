# Meli
[![Coverage Status](https://coveralls.io/repos/gullitmiranda/meli/badge.png)](https://coveralls.io/r/gullitmiranda/meli)
[![Build Status](https://travis-ci.org/gullitmiranda/meli.svg?branch=master)](https://travis-ci.org/gullitmiranda/meli)



__Meli__ gem interacts with the official [API Mercadolibre](https://api.mercadolibre.com).


## Installation

Add this line to your application's Gemfile:

    gem 'meli'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install meli

## Getting started

MELI uses OAuth protocol for authentication, so you first need to get an access token.

In order to do that you first need to instance the API:

```ruby
# config/initializers/meli.rb
Meli.configure do
  # Optional (is default)
  # Site Country
  # For other country check https://api.mercadolibre.com/sites/
  config.site_id = "MLB"

  # API url
  config.endpoint_url = "https://api.mercadolibre.com"

  # AUTH url
  config.auth_url = "http://auth.mercadolivre.com.br/authorization"
end
```

NOTE: All configs in [lib/config/meli.rb]( https://github.com/gullitmiranda/meli/blob/master/lib/config/meli.rb )

## Models Structure

  - __Meli::Category__ 
    - GET: [ all, find(id), first, last ]
  - __Meli::CategorySuggest__
    - GET: [ find("query") ]

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/gullitmiranda/meli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
