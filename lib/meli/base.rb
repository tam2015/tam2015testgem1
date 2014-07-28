require 'meli/oauth'

module Meli
  class Base < Meli::Oauth
    extend ActiveModel::Naming
    include CoreExt::Naming

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
        super options
      end



      def instantiate_collection(collection, original_params = {}, prefix_options = {})
        collection_parser.new(collection).tap do |parser|
          parser.klass            = self
          parser.name             = self.name
          parser.resource_class   = self
          parser.original_params  = original_params
        end.collect! { |record| instantiate_record(record, prefix_options) }
      end

    end

    ### Default ActiveResource settings overrides
    self.include_format_in_path = false
    self.collection_parser = Meli::Collection

    self.site= config.site
  end
end
