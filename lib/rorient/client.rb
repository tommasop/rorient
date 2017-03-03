require "faraday"

module Rorient
  class Client
    include Rorient::MetaQueries
    include Rorient::GraphQueries

    attr_reader :db

    def initialize(server:, user:, password:, scope: nil)
      @server = server
      @user = user
      @password = password
      @scope = scope
    end

    def connection
      Faraday.new(connection_options) do |faraday|
        faraday.request  :url_encoded                           # form-encode POST params
        faraday.request  :basic_auth, @user, @password          # basic authentication
        faraday.response :logger                                # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter                # make requests with Net::HTTP
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
