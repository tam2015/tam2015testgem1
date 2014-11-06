require "oauth2"

# Extend OAuth2::Response to provide compatibility between the two modes of
# connection, authenticating and unauthenticated.
module ResponseExtend
  extend ActiveSupport::Concern

  # Alias to response.status
  def code
    response.status
  end

  module ClassMethods
  end
end

OAuth2::Response.send(:include, ResponseExtend)
