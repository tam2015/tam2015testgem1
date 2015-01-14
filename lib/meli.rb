require "meli/version"

# dependencies
require "active_resource"
require 'active_support/configurable'
require 'active_support/inflector'
require "json"

# overrides
require 'oauth2/response_extend.rb'
require 'core_ext'

module Meli
  extend ::ActiveSupport::Autoload

  include ::ActiveSupport::Configurable


  # Core Models
  autoload :AccessToken
  autoload :Collection
  autoload :Base

  # Models
  autoload :Site
  autoload :Item
  autoload :Description
  autoload :Order
  autoload :Shipment
  autoload :Feedback
  autoload :Question
  autoload :User
  autoload :Trend

  autoload :Category
  autoload :CategorySuggest
end

require "config/meli"
