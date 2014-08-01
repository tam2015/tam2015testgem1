module Meli
  class Oauth < ActiveResource::Base

    @@oauth_connection = nil

    def self.oauth_connection= credentials
      if credentials.is_a? Hash
        credentials = Meli::AccessToken.from_hash client, credentials
      end
      @@oauth_connection = credentials
      connection(true)
      @@oauth_connection
    end

    def self.oauth_connection
      @@oauth_connection
    end

    def self.use_oauth= use_oauth
      @use_oauth = !!use_oauth
    end

    def self.use_oauth
      @use_oauth || false
    end

    def self.client
      if defined? @client
        @client
      else
        raise ArgumentError, "It requires a config.client_id, config.client_secret. Please check your \"config/meli.rb\" file." if !config.client_id or !config.client_secret

        options = {  }.merge(config)

        @client= OAuth2::Client.new(options.delete(:client_id), config.delete(:client_secret), options)
      end
    end

    def self.client=(client)
      @client = client
    end

    def self.connection(refresh = false)
      @connection = Connection.new(@@oauth_connection, @use_oauth, site, format) if @connection.nil? || refresh
      @connection.timeout = timeout if timeout
      return @connection
    end

    def format=(mime_type_reference_or_format)
      format = mime_type_reference_or_format.is_a?(Symbol) ?
      OauthActiveResource::Formats[mime_type_reference_or_format] : mime_type_reference_or_format
      self._format = format
      connection.format = format if site
    end

  end

  class Connection < ActiveResource::Connection
    def initialize(oauth_connection, use_oauth, *args)
      @use_oauth        = use_oauth
      @oauth_connection = oauth_connection

      super(*args)
    end

  private
    def request(method, path, *arguments)
      if @use_oauth
        if @oauth_connection == nil
          raise ArgumentError, "@oauth_connection was required for authentication."
        else
          if @oauth_connection.expired?
            @oauth_connection = @oauth_connection.refresh!
          end

          payload = { params: { access_token: @oauth_connection.token } }

          arguments.each do |argument|
            case argument
              when String
                payload[:body] = argument
              when Hash
                payload.merge!(argument)
            end
          end
          @oauth_connection.send(method, path, payload)
        end
      else
        super(method, path, *arguments)
      end

    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    end
  end
end
