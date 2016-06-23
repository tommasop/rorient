require "faraday"
require "faraday_connection_pool"
# Multi threaded http requests for puma
FaradayConnectionPool.configure do |config|
  config.size = 10 #The number of connections to held in the pool. There is a separate pool for each host/port.
  config.pool_timeout = 5 #If no connection is available from the pool within :pool_timeout seconds the adapter will raise a Timeout::Error.
  config.keep_alive_timeout = 30  #Connections which has been unused for :keep_alive_timeout seconds are not reused.
end

module Rorient
  class Client
    attr_reader :db

    def initialize(server:, user:, password:, scope: nil)
      @server = server
      @user = user
      @password = password
      @scope = scope
    end

    def connection
      Faraday.new(connection_options) do |faraday|
        faraday.request :retry, max: 2, interval: 0.05,
                     interval_randomness: 0.5, backoff_factor: 2
                     exceptions: [ Faraday::Error::ConnectionFailed ]
        faraday.request  :url_encoded                           # form-encode POST params
        faraday.request  :basic_auth, @user, @password          # basic authentication
        # faraday.response :logger                                # log requests to STDOUT
        faraday.adapter  :net_http_pooled #Faraday.default_adapter                # make requests with Net::HTTP
      end
    end

    def self.resources
      {
        document: DocumentResource,
        oclass: OClassResource,
        oproperty: OPropertyResource,
        query: QueryResource,
        command: CommandResource,
        batch: BatchResource
      }
    end

    def table_exists?(table_name)
      !oclass.find(class_name: table_name).nil?
    end

    def create_table(table_name)
      oclass.create(class_name: table_name)
    end
    
    def delete_table(table_name)
      oclass.delete(class_name: table_name)
    end

    def method_missing(name, *args, &block)
      if self.class.resources.keys.include?(name)
        resources[name] ||= self.class.resources[name].new(connection: connection, scope: @scope)
        resources[name]
      else
        super
      end
    end

    def resources
      @resources ||= {}
    end

    private

    def connection_options
      {
        url: @server,
        headers: {
          content_type: "application/json",
          content_length: "0", 
          accept_encoding: "gzip,deflate"
        }
      }
    end
  end
end
