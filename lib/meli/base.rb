require 'meli/oauth'

module Meli
  class Base < Meli::Oauth
    extend ActiveModel::Naming
    include CoreExt::Naming

    include ActiveModel::Dirty

    # Load Configs
    # class grab the configuration
    delegate :config, to: :class

    # ClassMethods
    class << self
      # Meli grab the configuration
      delegate :config, to: :parent


      # add sites/:site_id to find_every
      # ==== Examples:
      #   Meli::Base.find(1)
      #   # => GET /bases/1.json
      #
      #   Meli::Base.find(:all) or Meli::Base.all
      #   # => GET /sites/MLB/bases.json
      def include_site_id
        if defined?(@include_site_id)
          @include_site_id
        # elsif superclass != Object && superclass.include_site_id
        #   superclass.include_site_id.dup.freeze
        else
          false
        end
      end

      def include_site_id=(include_site_id)
        @include_site_id = !!include_site_id
      end

      def collection_path(*args)
        include_site_id ? "/sites/#{config.site_id}#{super(*args)}" : super(*args)
      end



      # Cached user_id
      # cattr_accessor :user_id
      def user_id=(id)
        @@user_id= id
      end

      def user_id
        @@user_id || User.me.id
      end

      def user_id?
        !!user_id
      end



      #######################
      #     Overrides
      #######################

      # Core method for finding resources. Used similarly to Active Record's +find+ method.
        #
        # ==== Arguments
        # The first argument is considered to be the scope of the query. That is, how many
        # resources are returned from the request. It can be one of the following.
        #
        # * <tt>:one</tt> - Returns a single resource.
        # * <tt>:first</tt> - Returns the first resource found.
        # * <tt>:last</tt> - Returns the last resource found.
        # * <tt>:all</tt> - Returns every resource that matches the request.
        #
        # ==== Options
        #
        # * <tt>:from</tt> - Sets the path or custom method that resources will be fetched from.
        # * <tt>:params</tt> - Sets query and \prefix (nested URL) parameters.
        #
        # ==== Examples
        #   Person.find(1)
        #   # => GET /people/1.json
        #
        #   Person.find(:all)
        #   # => GET /people.json
        #
        #   Person.find(:all, :params => { :title => "CEO" })
        #   # => GET /people.json?title=CEO
        #
        #   Person.find(:first, :from => :managers)
        #   # => GET /people/managers.json
        #
        #   Person.find(:last, :from => :managers)
        #   # => GET /people/managers.json
        #
        #   Person.find(:all, :from => "/companies/1/people.json")
        #   # => GET /companies/1/people.json
        #
        #   Person.find(:one, :from => :leader)
        #   # => GET /people/leader.json
        #
        #   Person.find(:all, :from => :developers, :params => { :language => 'ruby' })
        #   # => GET /people/developers.json?language=ruby
        #
        #   Person.find(:one, :from => "/companies/1/manager.json")
        #   # => GET /companies/1/manager.json
        #
        #   StreetAddress.find(1, :params => { :person_id => 1 })
        #   # => GET /people/1/street_addresses/1.json
        #
        # == Failure or missing data
        # A failure to find the requested object raises a ResourceNotFound
        # exception if the find was called with an id.
        # With any other scope, find returns nil when no data is returned.
        #
        #   Person.find(1)
        #   # => raises ResourceNotFound
        #
        #   Person.find(:all)
        #   Person.find(:first)
        #   Person.find(:last)
        #   # => nil
      def find(*arguments, &block)
        scope   = arguments.slice!(0)
        options = arguments.slice!(0) || {}

        case scope
          when :all   then find_every(options, &block)
          when :first then find_every(options).first
          when :last  then find_every(options).last
          when :one   then find_one(options)
          else             find_single(scope, options)
        end
      end

      # This is an alias for find(:all). You can pass in all the same
      # arguments to this method as you can to <tt>find(:all)</tt>
      def all(*args, &block)
        find(:all, *args, &block)
      end

      def find_every(options, &block)
        collection = super options
        if block_given?
          # resoucers, data, options
          yield(collection, {}, options)
        end
        collection
      end


      # Find a single resource from the default URL with optional instantiate
      def find_single(scope, options, instantiate=true)
        prefix_options, query_options = split_options(options[:params])
        path = element_path(scope, prefix_options, query_options)
        record = format.decode(connection.get(path, headers).body)
        if instantiate
          instantiate_record(record, prefix_options)
        else
          record
        end
      end



      def instantiate_collection(collection, original_params = {}, prefix_options = {})
        collection_parser.new(collection).tap do |parser|
          parser.klass            = self
          parser.name             = self.name
          parser.resource_class   = self
          parser.original_params  = original_params
        end.collect! { |record| instantiate_record(record, prefix_options) }
      end


      def load(attributes, remove_root = false, persisted = false)
        raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
        @prefix_options, attributes = split_options(attributes)

        if attributes.keys.size == 1
          remove_root = self.class.element_name == attributes.keys.first.to_s
        end

        attributes = Formats.remove_root(attributes) if remove_root

        attributes.each do |key, value|
          attr_value =  case value
                          when Array
                            resource = nil
                            value.map do |attrs|
                              if attrs.is_a?(Hash)
                                resource ||= find_or_create_resource_for_collection(key)
                                resource.new(attrs, persisted)
                              else
                                attrs.duplicable? ? attrs.dup : attrs
                              end
                            end
                          when Hash
                            resource = find_or_create_resource_for(key)
                            resource.new(value, persisted)
                          else
                            value.duplicable? ? value.dup : value
                        end

          self.send("#{key.to_s}", attr_value)
        end

        @default_attributes = @attributes

        define_attribute_methods @attributes.symbolize_keys.keys

        self
      end

    end




    # InstanceMethods

    ### Default ActiveResource settings overrides
    self.include_format_in_path = false
    self.collection_parser = Meli::Collection

    self.site= config.site



    def attribute(attribute_name)
      attributes[attribute_name]# if attributes.include? attribute_name
    end

    def serializable_hash(options={})
      ActiveSupport::HashWithIndifferentAccess[super.map { |record| recursive_serializable_hash(record, options) }]
    end

    def recursive_serializable_hash(record, *args)
      if record.is_a? Array
        record.map! {|v| recursive_serializable_hash(v, *args)  }
      elsif record.respond_to?(:serializable_hash)
        record.serializable_hash(*args)
      else
        record
      end
    end

    def save
      saved = super

      # do persistence work
      changes_applied if saved
      saved
    end

    def attributes_changed
      ActiveSupport::HashWithIndifferentAccess[changed.map { |attr| [attr, __send__(attr)] }]
    end

    def encode_changes(options={})
      attributes_changed.send("to_#{self.class.format.extension}", options)
    end

    # A method to \reload the attributes of this object from the remote web service.
    alias_method :reload!, :reload

    # Reset changes
    def reload
      reset_changes
    end


    protected

      # Update the resource on the remote service.
      def update
        run_callbacks :update do
          connection.put(element_path(prefix_options), encode_changes, self.class.headers).tap do |response|
            load_attributes_from_response(response)
          end
        end
      end

      # Load attributes from Response or OAuth2::Response
      def load_attributes_from_oauth2_response(response)
        if (response_code_allows_body?(response.status) &&
            (response.headers["content-length"].nil? || response.headers["content-length"] != "0") &&
            !response.body.nil? && response.body.strip.size > 0)
          load(self.class.format.decode(response.body), true, true)
          @persisted = true
        end
      end

      def load_attributes_from_response(response)
        if response.is_a? OAuth2::Response
          load_attributes_from_oauth2_response response
        else
          super response
        end
      end



      def method_missing(method_symbol, *arguments) #:nodoc:
        method_name = method_symbol.to_s

        if method_name =~ /(=|\?|<<)$/
          case $1
          when "="
            class_eval do
              define_attribute_method $`.to_sym
            end
            self.send("#{$`}_will_change!") unless arguments.first == attribute($`)
            attributes[$`] = arguments.first
          when "<<"
            val = attribute($`) + arguments.first
            self.send("#{$`}=", val)
          when "?"
            attributes[$`]
          end
        else
          return attribute(method_name) if attributes.include?(method_name)
          # return attributes[method_name] if attributes.include?(method_name)
          # not set right now but we know about it
          return nil if known_attributes.include?(method_name)
          super
        end
      end

    private

      # Create and return a class definition for a resource inside the current resource
      def create_resource_for(resource_name)
        resource = self.class.const_set(resource_name, Class.new(Meli::Base))
        resource.prefix = self.class.prefix
        resource.site   = self.class.site
        resource
      end
  end
end
