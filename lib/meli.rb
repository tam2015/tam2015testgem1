require "meli/version"

# dependencies
require "active_resource"
require 'active_support/configurable'
require 'active_support/inflector'
require "json"

module Meli
  extend ::ActiveSupport::Autoload

  include ::ActiveSupport::Configurable
end

require "config/meli"
