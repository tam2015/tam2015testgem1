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

    def description(force = false)
      if description? and !force
        description?
      elsif descriptions? and self.id?
        @description_klass = find_or_create_resource_for_collection(:description)
        @description_klass.find_every(params: { item_id: self.id }).first
      end
    end



    # Validate to publish
    # permited attributes:
      # [:buying_mode, :listing_type_id, :status, :accepts_mercadopago,
      #   :automatic_relist, :available_quantity, :catalog_product_id, :category_id,
      #   :condition, :coverage_areas, :currency_id, :description, :location,
      #   :non_mercado_pago_payment_methods, :official_store_id, :pictures, :price,
      #   :seller_address, :seller_custom_field, :shipping, :site_id, :start_time,
      #   :title, :variations, :video_id, :warranty]

    def serializable_shipping
      if shipping = self.shipping?
        shipping_hash = ActiveSupport::HashWithIndifferentAccess.new
        shipping_hash[:local_pick_up] = shipping.local_pick_up?.to_bool # FORCE Boolean

        # if shipping.free_shipping?
        #   shipping_hash[:free_shipping ] = shipping.free_shipping.to_bool # FORCE Boolean
        # end

        case shipping_hash[:mode] = shipping.mode?
        when "me1"
          # code here
        when "me2"
          # code here

        # when "custom"
          # TO FIX: https://gist.github.com/gullitmiranda/2ba389dbb5bbf3378c8f#file-shipping_custom-json
          # shipping_hash[:costs] = (shipping.costs? || []).map do |cost|
          #   {
          #     name: cost.name?,
          #     cost: cost.cost?.to_f # FORCE Float
          #   }
          # end
        else
          shipping_hash.delete(:mode)
        end

        shipping_hash[:dimensions] = shipping.dimensions? if shipping.dimensions?

        shipping_hash
      end
    end

    def serializable_non_mercado_pago_payment_methods
      if methods = self.non_mercado_pago_payment_methods?
        methods.map do |method|
          method.is_a?(String) ? { id: method } : method
        end
      end
    end

    def attributes_to_encode
      hash = ActiveSupport::HashWithIndifferentAccess.new({
        title:                            self.title?                                       , # Test Item - Do Not Bid
        buying_mode:                      self.buying_mode?                                 , #
        listing_type_id:                  (self.listing_type_id?  || :bronze).to_s          , # bronze  - FORCE String
        status:                           self.status?                                      , #
        accepts_mercadopago:              self.accepts_mercadopago?                         , #
        automatic_relist:                 self.automatic_relist?                            , #
        available_quantity:               self.available_quantity?.to_i                     , # 1       - FORCE Integer
        catalog_product_id:               self.catalog_product_id?                          , #
        category_id:                      self.category_id?                                 , # MLA3530
        condition:                        self.condition?.to_s                              , # new     - FORCE String
        currency_id:                      (self.currency_id? || "BRL")                      , # BRL
        description:                      self.description?                                 , #
        non_mercado_pago_payment_methods: self.serializable_non_mercado_pago_payment_methods, # non_mercado_pago_payment_methods to Map (array of hash)
        official_store_id:                self.official_store_id?                           , #
        price:                            self.price?.to_f                                  , # 10      - FORCE Float
        seller_custom_field:              self.seller_custom_field?                         , #
        site_id:                          self.site_id?                                     , #
        start_time:                       self.start_time?                                  , #
        video_id:                         self.video_id?                                    , #
        warranty:                         self.warranty?                                      #
      })

      hash[:location      ] = self.location               if self.location?
      hash[:coverage_areas] = self.coverage_areas         if self.coverage_areas?

      hash[:shipping      ] = self.serializable_shipping  if self.shipping?       # shipping to hash normalized
      hash[:seller_address] = self.seller_address         if self.seller_address?
      hash[:seller_contact] = self.seller_contact         if self.seller_contact?

      hash[:variations    ] = self.variations             if self.variations?
      hash[:pictures      ] = self.pictures               if self.pictures?

      hash
    end

    def encode(options = {})
      attributes_to_encode.send("to_#{self.class.format.extension}", options)
    end

    def validate(opts={})
      run_callbacks :validate do
        opts = {
          raise_errors: false
        }.merge(opts)

        puts "\n\n\n"
        puts " ----  Validate item -----"
        puts " --> path: #{collection_path}/validate"
        puts " --> encode: #{encode}"
        puts " --> opts: #{opts}"
        puts "\n\n\n"
        old_status = self.status?

        connection.post("#{collection_path}/validate", encode, opts).tap do |response|
          puts " --> response status: #{response.status}"
          puts " --> response error: {#{response.error.present?}} (#{response.error.class}) #{response.error.inspect}"
          puts " --> response parsed: #{response.parsed}"

          load_attributes_from_response(response)

          # use old_status instead of response.status
          self.attributes[:status] = old_status if self.status == response.status

          # 200..299      - ok
          # 301..303, 307 - redirecting
          # 300..399      - non-redirecting 3xx statuses
          # 402           - payment required
          # 400..599      - all errors statutes
          self.validation_code = response.status

          case response.status
          when 200..299, 300..399
            self.status = :unpublished

            self.validation_status = :valid
            self.validation_errors = nil
          when 402
            self.status = :payment_required

            self.validation_status = :valid
            self.validation_errors = nil
          else
            self.status = :invalid_data

            cause   = response.parsed["cause"]
            error   = response.parsed["error"]
            message = response.parsed["message"]
            if cause.present?
              self.validation_status = cause.first["code"].gsub(/^item\./, '')
              self.validation_errors = cause
            elsif error.present?
              self.validation_status = message
              self.validation_errors = [
                {
                  "code"    => error,
                  "message" => message
                }
              ]
            else
              self.validation_status = response.status
              self.validation_errors = cause
            end
          end
        end
      end
    end
  end
end
