module Meli
  class Item < Meli::Base
    self.use_oauth = true


    # Get all item ids
    #
    # @oaram [Hash] options:
    #   :user_id      [String ] default: User.me
    #   :limit        [Integer] default: 50 (is max)        - maximum number of items per request
    #   :offset       [Integer] default: 0 (is min)         - set the initial number
    #   :pages_limit  [Integer] default: -1 (-1 no limite)  - limit of pages to be requested

    def self.all_ids(options={}, &block)
      user_id = options.delete(:user_id) || User.me.id

      options.reverse_merge!({limit: 50,
                              offset: 0,
                              pages: -1,
                              page:   0 })

      from = "/users/#{user_id}#{collection_path}/search"

      has_results = true
      ids = []

      while has_results && options[:pages] != options[:page] do
        params = {  limit:  options[:limit],
                    offset: options[:offset] }

        path = "#{from}#{query_string(params)}"
        data = format.decode(connection.get(path, headers).body) || []


        results = data["results"]
        has_results = (results.any? and results.count == options[:limit])

        options[:page   ] += 1
        options[:offset ] += options[:limit]

        yield(results, data, options) if block_given?

        ids.concat results
      end

      ids
    end

    # Find every resource
    def self.find_every(options, &block)
      collection = []

      all_ids(options) do |partial_ids, data, opts|
        partial_items = partial_ids.map do |id|
          find_single(id, options, false)
        end

        if block_given?
          yield(instantiate_collection( partial_items ), data, opts)
        end

        collection.concat partial_items
      end

      instantiate_collection( collection )
    end

    # Find a single resource from the default URL
    def self.find_single(scope, options, instantiate=true)
      prefix_options, query_options = split_options(options[:params])
      path = element_path(scope, prefix_options, query_options)
      record = format.decode(connection.get(path, headers).body)
      if instantiate
        instantiate_record(record, prefix_options)
      else
        record
      end
    end
  end
end
