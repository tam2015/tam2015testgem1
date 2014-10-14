
v0.0.9 / 2014-10-14 
==================

 * isolating `auth_connection`
 * dump version to v0.0.8
 * fix #2: undefined method `token` with no auth required
 * bump version 0.0.7
 * fixed openssl and ML ssl version;
 * bump version 0.0.6
 * [item/description] create association to descriptions;
 * fixed find_single no option instantiate;
 * bump version
 * [order] create Shipment assoction to Order
 * fixed method `<<` not working;
 * bump version 0.0.4
 * [oauth] fixed oauth_connection and connection overrides with other threads
 * bump version 0.0.3
 * update oauth2
 * change gem homepage
 * fixed WARNING because unseted gem dependecies version
 * fixed WARNING because unseted gem dependecies version
 * bump version 0.0.2
 * Meli::Order
 * Find a single resource from the default URL with optional instantiate;
 * add method Base.user_id;
 * fixed not load user_id from options
 * disable codeclimate
 * recursive_serializable_hash
 * fixed find_single not instantiate record
 * remove development config.client_id and config.callback_url
 * fixed argmuents to post or put using oauth_connection.
 * fixed find_single not instantiate record by default.
 * add RAKE_ENV
 * fixed undefined method `code` to OAuth2::Response;
 * ActiveModel::Dirty to attributes
 * update oauth_connection after access_token.refresh!
 * git ignore temp lib files replace (started with underscore);
 * fixed conflict oauth 0.9.4 in omniauth-mercadolibre
 * add env to Rakefile
 * fixed not update Meli::Base.oauth_connection after refresh token.
 * access_token_spec
 * fixed override Oauth2::AccessToken
 * new resources:  - User  - Item
 * suported to oauth
 * fixed override attributes :name and :model_name
 * remove rvm rbx-2 travis
 * fixed ruby 1.9 invalid multibyte char and add CODECLIMATE_REPO_TOKEN to travis.yml
 * fixed ruby 1.9 invalid multibyte char
 * add Code Climate and remove Coveralls
 * fixed unexpected  in to_snake_keys_spec.rb
 * Add Ruby 2.1.2 to Travis build matrix
