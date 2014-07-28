module OAuth2
  class AccessToken
    # Refreshes the current Access Token
    #
    # @return [AccessToken] a new AccessToken
    # @note options should be carried over to the new AccessToken
    def refresh!(params = {})
      new_token = super
      # OAuth2::Error: invalid_grant: {"message":"Error validating grant. Your authorization code or refresh token may be expired or it was already used.","error":"invalid_grant","status":400,"cause":[]}

      # Callback
      if Meli.config.after_refresh_token and Meli.config.after_refresh_token.respond_to? :call
        Meli.config.after_refresh_token.call new_token, self
      end

      new_token
    end
  end
end
