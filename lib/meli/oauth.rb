module Meli
  class Oauth < ActiveResource::Base

    @@oauth_connection = nil

    self.ssl_options= {
      version: "SSLv3"
    }

    def self.oauth_connection= credentials
      if credentials.is_a? Hash
        credentials = Meli::AccessToken.from_hash client, credentials
      end
      Thread.current[:oauth_connection] = credentials
      connection(true)
      Thread.current[:oauth_connection]
    end

    def self.oauth_connection
      Thread.current[:oauth_connection]
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

        options = {
          ssl: ssl_options
       }.merge(config)

        @client= OAuth2::Client.new(options.delete(:client_id), config.delete(:client_secret), options)
      end
    end

    def self.client=(client)
      @client = client
    end


    def self.connection?
      !!Thread.current[:connection]
    end

    def self.connection(refresh = false)
      if !connection? || refresh
        Thread.current[:connection] = Connection.new(oauth_connection, use_oauth, site, format)
      end
      Thread.current[:connection].timeout = timeout if timeout
      Thread.current[:connection].use_oauth = use_oauth
      return Thread.current[:connection]
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

    def use_oauth
      @use_oauth
    end

    def use_oauth= use_oauth
      @use_oauth= use_oauth
    end

  private

    def request(method, path, *arguments)
      puts "\n\n\n ---> connection #{@oauth_connection.inspect}"
      puts " ---> self #{self.inspect}"
      puts " ---> method #{method}"
      puts " ---> path #{path}"
      puts " ---> token #{@oauth_connection.token}" if @oauth_connection
      puts " ---> use_oauth #{@use_oauth}"
      puts " ---> arguments #{arguments}"
      puts " ---> site #{site.inspect}"
      if @use_oauth
        if @oauth_connection == nil
          raise ArgumentError, "@oauth_connection was required for authentication."
        else
          puts " ---> with auth -----"
          puts " ---> expired? #{@oauth_connection.expired?}"
          puts " ---> token #{@oauth_connection.token}"

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

          puts " ---> payload to send: #{[payload]}"

          response = @oauth_connection.send(method, path, payload)
          puts " ---> response: #{response.inspect}"
          puts " ---> response.body: #{response.body}"
          response
        end
      else
        puts " ---> no auth ----"
        super(method, path, *arguments)
      end

    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    end
  end
end
