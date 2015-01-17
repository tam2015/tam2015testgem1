# Meli
[![Code Climate](https://codeclimate.com/github/gullitmiranda/meli.png)](https://codeclimate.com/github/gullitmiranda/meli)
[![Test Coverage](https://codeclimate.com/github/gullitmiranda/meli/coverage.png)](https://codeclimate.com/github/gullitmiranda/meli)
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
  # REQUIRED for authentication
  config.client_id      = ENV['MERCADOLIBRE_APP_ID'       ]
  config.client_secret  = ENV['MERCADOLIBRE_APP_SECRET'   ]
  config.callback_url   = ENV['MERCADOLIBRE_CALLBACK_URL' ]

  # Optional (is default)
  # Site Country
  # For other country check https://api.mercadolibre.com/sites/
  config.site_id = "MLB"

  # API url
  config.site = "https://api.mercadolibre.com"

  # AUTH url
  config.authorize_url   = "http://auth.mercadolivre.com.br/authorization"
  config.token_url  = "/oauth/token"

  config.after_refresh_token = nil
end
```

NOTE: All configs in [lib/config/meli.rb]( https://github.com/gullitmiranda/meli/blob/master/lib/config/meli.rb )

## Endpoints

- __Meli::Category__ (not implemented)

- __Meli::CategorySuggest__ (not implemented)

- __Meli::Item__

```ruby
Meli::Item.all_ids(opts, &block)
Meli::Item.find_every(opts, &block) # (uses all_ids)
Meli::Item.validate(opts)
```

- __Meli::User__

```ruby
Meli::User.me
```

- __Meli::Shipment__

```ruby
Meli::Shipment.find(shipment_id)
Meli::Shipment.find_by_order_id(order_id)
Meli::Shipment.set_delivered!(shipment_id)
Meli::Shipment.user_preferences(customer_id)
Meli::Shipment.options_by_item_id(item_id)
Meli::Shipment.methods_by_item_id(item_id)
Meli::Shipment.services_by_item_id(item_id)
Meli::Shipment.calculate_cost(customer_id, zip_code, dimensions, weight)
Meli::Shipment.calculate_cost_by_site_id(site_id, zip_code_from, zip_code_to, dimensions, weight)
Meli::Shipment.available_category_filters_for_customer(customer_id, category_id)
Meli::Shipment.print_label(shipment_ids)
```

- __Meli::Feedback__

```ruby
Meli::Feedback.find_by_order_id(order_id)

feedback_params = {
  "fulfilled" => true,
  "rating"    => "neutral",
  "message"   => "fine",
  "reason"    => "THEY_DIDNT_ANSWER"
}
Meli::Feedback.post_feedback(order_id, feedback_params)

Meli::Feedback.post_sale_feedback(order_id, params)
Meli::Feedback.get_purchase_feedback(order_id)
Meli::Feedback.post_purchase_feedback(order_id, params)
Meli::Feedback.reply_feedback(feedback_id, params)
```

- __Meli::Trend__

```ruby
Meli::Trend.find(site_id)
Meli::Trend.find_by_category_id(site_id, category_id)
```

- __Meli::Trend__

```ruby
Meli::Question.find(question_id)
Meli::Question.find_by_item_id(item_id)
Meli::Question.ask_question(item_id, params)
Meli::Question.answer_question(question_id, params)
Meli::Question.list_blacklist(user_id)
Meli::Question.add_user_to_blacklist(user_id)
Meli::Question.remove_user_from_blacklist(user_id)
Meli::Question.all_questions(params)
```

## Updating gem
You will need to add Gemfury as a remote repository for Meli:

```bash
$ git remote add fury https://git.fury.io/aircrm/meli.git
```

And upload the source content with:

```bash
$ git push fury master
```

## Contributing

1. Fork it ( https://github.com/gullitmiranda/meli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
