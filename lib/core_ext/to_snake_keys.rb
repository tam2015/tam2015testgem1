require 'active_support/inflector'

class Symbol
  def underscore
    to_s.underscore.to_sym
  end
end

module ToSnakeKeys
  # Recursively converts CamelCase and camelBack JSON-style hash keys to
  # Rubyish snake_case, suitable for use during instantiation of Ruby
  # model attributes.
  #
  def underscore(value = self, others = true)
    if value.is_a?(String) or value.is_a?(Symbol)
      value = value.underscore if others
    end

    case value
      when Array
        value.map! { |v| underscore(v, false) }
      when Hash
        Hash[value.map { |k, v| [underscore(k), underscore(v, false)] }]
      else
        value
    end
  end
end

Array.send  :include, ToSnakeKeys
 Hash.send  :include, ToSnakeKeys
