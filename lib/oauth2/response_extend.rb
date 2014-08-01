require "oauth2"

module ResponseExtend
  extend ActiveSupport::Concern

  # The HTTP response status code
  def code
    response.status
  end

  module ClassMethods
  end
end

OAuth2::Response.send(:include, ResponseExtend)
