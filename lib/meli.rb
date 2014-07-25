require "meli/version"

# dependencies
require "active_resource"
require 'active_support/configurable'
require 'active_support/inflector'
require "json"

# overrides
require 'core_ext'

module Meli
  extend ::ActiveSupport::Autoload

  include ::ActiveSupport::Configurable


  # Core Models
  autoload :Collection
  autoload :Base

  # Models
  autoload :Category
  autoload :CategorySuggest
end

require "config/meli"
