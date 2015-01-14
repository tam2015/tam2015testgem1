require 'oauth2'

module Meli
  class AccessToken < OAuth2::AccessToken
    # Refreshes the current Access Token
    #
    # @return [Meli::AccessToken] a new Meli::AccessToken
    # @note options should be carried over to the new Meli::AccessToken
    def refresh!(params = {})
      # puts " # Meli::AccessToken.refresh!"

      new_token = super

      # Callback
      if Meli.config.after_refresh_token and Meli.config.after_refresh_token.respond_to? :call
        Meli.config.after_refresh_token.call new_token, self
      end

      new_token
    end
  end
end
