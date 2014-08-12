module Meli
  class Order < Meli::Base
    self.use_oauth = true

    cattr_accessor :options

    def self.default_options
      { limit: 50,
        offset: 0,
        pages: -1,
        page:   0,
        kind:   [:recent, :archived],
        seller: nil }
    end

    def self.options=(opts)
      @options = default_options.merge(opts)
    end

    def self.options
      unless defined? @options
        @options = default_options
        @options[:seller] = user_id
      end
      @options
    end

    def self.kind_path(kind)
      "#{collection_path}/search/#{kind.to_s}"
    end

    def self.find_kind(kind, opts, &block)
      from = kind_path kind
      opts = options.merge opts

      has_results = true
      kind_orders = []
      opts[:kind] = kind

      while has_results && opts[:pages] != opts[:page] do
        params = {  limit:  opts[:limit ],
                    offset: opts[:offset],
                    seller: opts[:seller] }

        path = "#{from}#{query_string(params)}"
        data = format.decode(connection.get(path, headers).body) || []


        results = data["results"]
        has_results = (results.any? and results.count == opts[:limit])

        if block_given?
          yield(instantiate_collection( results ), data, opts)
        end

        opts[:page   ] += 1
        opts[:offset ] += opts[:limit]

        kind_orders.concat results
      end
      kind_orders
    end

    # Find every orders
    #
    # @oaram [Hash] options:
    #   :seller       [String ] default: User.me
    #   :limit        [Integer] default: 50 (is max)        - maximum number of orders per request
    #   :offset       [Integer] default: 0 (is min)         - set the initial number
    #   :pages_limit  [Integer] default: -1 (-1 no limite)  - limit of pages to be requested
    def self.find_every(opts, &block)
      opts = options.merge opts

      collection = []
      [opts[:kind]].flatten.each do |kind_path|
        collection.concat find_kind(kind_path, opts, &block)
      end

      instantiate_collection( collection )
    end
  end
end
