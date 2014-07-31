require 'oauth2'

module Meli
  class AccessToken < OAuth2::AccessToken
    # Refreshes the current Access Token
    #
    # @return [Meli::AccessToken] a new Meli::AccessToken
    # @note options should be carried over to the new Meli::AccessToken
    def refresh!(params = {})
      new_token = super
      # OAuth2::Error: invalid_grant: {"message":"Error validating grant. Your authorization code or refresh token may be expired or it was already used.","error":"invalid_grant","status":400,"cause":[]}
      puts " ---> refresh! #{new_token} -----"

      # Callback
      Meli::Base.oauth_connection = new_token

      if Meli.config.after_refresh_token and Meli.config.after_refresh_token.respond_to? :call
        Meli.config.after_refresh_token.call new_token, self
      end

      new_token
    end
  end
end
