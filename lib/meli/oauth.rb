module Meli
  class Oauth < ActiveResource::Base
    attr_accessor :auth_client
    cattr_accessor :auth_ssl_options

    @@oauth_connection = nil

    # self.auth_ssl_options= {
    #   ssl: { version: "SSLv3"}
    # }

    # self.ssl_options= {
    #   ssl_version: 'SSLv3'
    # }

    def self.oauth_connection= credentials
      if credentials.is_a? Hash
        credentials = Meli::AccessToken.from_hash auth_client, credentials
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

    def self.auth_client
      if defined? @auth_client
        @auth_client
      else
        raise ArgumentError, "It requires a config.client_id, config.client_secret. Please check your \"config/meli.rb\" file." if !config.client_id or !config.client_secret

        options = (auth_ssl_options || {}).merge(config)

        @auth_client = OAuth2::Client.new(options.delete(:client_id), options.delete(:client_secret), options)
      end
    end

    def self.auth_client=(auth_client)
      @auth_client = auth_client
    end

    def self.connection?
      if use_oauth
        !!Thread.current[:auth_connection]
      else
        !!@connection
      end
    end

    def self.refresh_connection
      @connection = Connection.new(nil, use_oauth, site, format)
      @connection.timeout     = timeout     if timeout
      @connection.use_oauth   = use_oauth   if use_oauth
      @connection.ssl_options = ssl_options if ssl_options and site and site.scheme == "https"
    end

    def self.refresh_auth_connection
      Thread.current[:auth_connection] = Connection.new(oauth_connection, true, site, format)
      Thread.current[:auth_connection].proxy       = proxy        if proxy
      Thread.current[:auth_connection].user        = user         if user
      Thread.current[:auth_connection].password    = password     if password
      Thread.current[:auth_connection].auth_type   = auth_type    if auth_type
      Thread.current[:auth_connection].ssl_options = ssl_options  if ssl_options
      Thread.current[:auth_connection].timeout     = timeout      if timeout
      Thread.current[:auth_connection].use_oauth   = use_oauth    if use_oauth
      Thread.current[:auth_connection]
    end

    def self.connection(refresh = false)
      if refresh
        refresh_auth_connection
        refresh_connection
      end

      if use_oauth
        refresh_auth_connection if !Thread.current[:auth_connection]
        Thread.current[:auth_connection]
      else
        refresh_connection if @connection.nil?
        @connection
      end
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
      # puts "\n\n\n# Meli::Connection.request..."
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
                payload[:headers] ||= {}

                if argument.include?(:headers)
                  payload[:headers].merge!(argument[:headers])
                  argument.delete(:headers)
                end

                if argument.include?("Content-Type")
                  payload[:headers]["Content-Type"] = argument["Content-Type"]
                  argument.delete("Content-Type")
                end

                payload.merge!(argument)
            end
          end

          # Debugger
          # puts "\n\n"
          # puts"* Meli::Request: -------------------------------"
          # puts "# method: #{method.inspect}"
          # puts "# path: #{path.inspect}"
          # puts "# arguments: #{arguments.inspect}"
          # puts "\n# payload: #{payload.inspect}"
          # puts "\n\n"

          response = @oauth_connection.send(method, path, payload)

          response
        end
      else
        super(method, path, *arguments)
      end

    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    end
  end
end
