module Meli
  class Item < Meli::Base
    self.use_oauth = true

    has_many :description, class_name: "Meli::Description"
    # has_one :description, class_name: "Meli::Description"
    # belongs_to :description, class_name: "Meli::Description"


    cattr_accessor :options

    class << self
      # def initialize(attributes = {}, persisted = false)
      #   @attributes     = {}.with_indifferent_access
      #   @prefix_options = {}
      #   @persisted = persisted
      #   load(attributes, false, persisted)
      # end

      # def instantiate_record(record, prefix_options = {})
      #   new(record, true).tap do |resource|
      #     resource.prefix_options = prefix_options
      #     resource.description_id = resource.descriptions.first.id
      #   end
      # end


      def default_options
        { limit: 50,
          offset: 0,
          pages: -1,
          page:   0,
          seller: nil }
      end

      def options=(opts)
        @options = default_options.merge(opts)
      end

      def options
        unless defined? @options
          @options = default_options
          @options[:seller] = user_id
        end
        @options
      end

      # Get all item ids
      #
      # @oaram [Hash] options:
      #   :user_id      [String ] default: User.me
      #   :limit        [Integer] default: 50 (is max)        - maximum number of items per request
      #   :offset       [Integer] default: 0 (is min)         - set the initial number
      #   :pages_limit  [Integer] default: -1 (-1 no limite)  - limit of pages to be requested

      def all_ids(opts={}, &block)
        user_id = options.delete(:user_id) || User.me.id

        opts = options.merge opts

        from = "/users/#{user_id}#{collection_path}/search"

        has_results = true
        ids = []

        puts "\n\n\n"
        puts "opts= #{opts}"
        puts "\n\n\n"

        while has_results && opts[:pages] != opts[:page] do
          params = {  limit:  opts[:limit],
                      offset: opts[:offset] }

          path = "#{from}#{query_string(params)}"
          data = format.decode(connection.get(path, headers).body) || []


          results = data["results"]
          has_results = (results.any? and results.count == opts[:limit])

          opts[:page   ] += 1
          opts[:offset ] += opts[:limit]

          yield(results, data, options) if block_given?

          ids.concat results
        end

        ids
      end

      # Find a single resource from the default URL with optional instantiate
      # def find_single(scope, options, instantiate=true)
      #   prefix_options, query_options = split_options(options[:params])
      #   path = element_path(scope, prefix_options, query_options)
      #   record = format.decode(connection.get(path, headers).body)
      #   if instantiate
      #     instantiate_record(record, prefix_options)
      #   else
      #     record
      #   end
      # end


      # Find every resource
      def find_every(opts, &block)
        collection = []

        all_ids(opts) do |partial_ids, data, partial_opts|
          partial_items = partial_ids.map do |id|
            puts "\n\n\n"
            puts "here? (#{self}) (#{parent})"
            puts "here? (#{ancestors})"
            puts "\n\n\n"

            find_single(id, opts, false)
          end

          if block_given?
            yield(instantiate_collection( partial_items ), data, opts)
          end

          collection.concat partial_items
        end

        instantiate_collection( collection )
      end
    end

    def as_json(options)
      super.merge( description: description )
    end

    def description
      unless descriptions.empty?
        @description_klass = find_or_create_resource_for_collection(:description)
        @description_klass.find_every(params: { item_id: self.id }).first
      end
    end
  end
end
