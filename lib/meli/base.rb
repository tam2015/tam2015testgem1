module Meli
  class Base < ActiveResource::Base
    extend ActiveModel::Naming
    include CoreExt::Naming

    # Load Configs
    # class grab the configuration
    delegate :config, to: :class

    # ClassMethods
    class << self
      # Meli grab the configuration
      delegate :config, to: :parent

      def collection_path(*args)
        include_site_id ? "/sites/#{config.site_id}#{super}" : super
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

    # add sites/:site_id to find_every
    # ==== Examples:
    #   Meli::Base.find(1)
    #   # => GET /bases/1.json
    #
    #   Meli::Base.find(:all) or Meli::Base.all
    #   # => GET /sites/MLB/bases.json
    cattr_accessor(:include_site_id) { false }

    self.site= config.endpoint_url
  end
end
