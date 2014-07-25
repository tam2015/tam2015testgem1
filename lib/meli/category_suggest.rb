module Meli
  class CategorySuggest < Meli::Base
    self.site= "http://syi.mercadolivre.com.br/category"
    self.collection_name = "suggest"

    class << self
      # move scope to params (query_string)
      def scope_to_params(scope, options)
        options[:params] = (options[:params] || {}).merge({ q: scope })
        options
      end

      private

        # Find a single resource from the default URL
        def find_single(scope, options)
          # move scope to query_string
          options = scope_to_params scope, options

          prefix_options, query_options = split_options(options[:params])

          # use collection instead of element
          path = collection_path(prefix_options, query_options)

          # recursive underscore keys
          body = format.decode(connection.get(path, headers).body).underscore
          instantiate_collection(body, prefix_options)
        end
    end
  end
end
