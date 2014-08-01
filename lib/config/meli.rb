Meli.configure do |config|
  # REQUIRED for authentication
  config.client_id      = ENV['MERCADOLIBRE_APP_ID'       ]
  config.client_secret  = ENV['MERCADOLIBRE_APP_SECRET'   ]
  config.callback_url   = ENV['MERCADOLIBRE_CALLBACK_URL' ]

  # Envs for development
  if ENV["RACK_ENV"] == "test" and ENV["RACK_ENV"] != "production"
    config.client_id      = "1551683306174268"
    config.client_secret  = "jVig8f30muP7JXgk8AsP6R4icK9wDj2C"
  end

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
