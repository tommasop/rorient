require "rorient/version"
require "resource_kit"
require "oj"
require "active_support/inflector"
require "active_support/core_ext/object/blank"
require "securerandom"
require "loga"

unless defined?(Rails)
  # Loga initialization based on previous
  # configuration if existing or rescue error
  # to provide new configuration
  begin 
    Loga.configuration.service_name = "RORIENT"
    Loga.logger.formatter = Loga.configuration.send(:assign_formatter)
  rescue Loga::ConfigurationError
    Loga.configure(
      filter_parameters: [:password],
      level: ENV["LOG_LEVEL"] || "DEBUG",
      format: :gelf,
      service_name: "RORIENT",
      tags: [:uuid]
    )
  end
end

# Always parse string keys into symbols
Oj.default_options = {:symbol_keys => true}

module Rorient
  autoload :Client, "rorient/client"
  
  # Utils to deal with OrientDB rids and batches
  autoload :Rid, "rorient/utils/rid"
  autoload :Batch, "rorient/utils/batch"
  autoload :Format, "rorient/utils/format"

  # Data modeling classes
  autoload :Base, "rorient/models/base"
  autoload :Vertex, "rorient/models/vertex"
  autoload :NodesRetriever, "rorient/models/nodes_retriever"
  autoload :Edge, "rorient/models/edge"

  # OrientDB HTTP API Endpoints
  #autoload :Server, "rorient/resources/server"
  autoload :DocumentResource, "rorient/resources/document_resource"
  autoload :OClassResource, "rorient/resources/oclass_resource"
  autoload :OPropertyResource, "rorient/resources/oproperty_resource"
  autoload :QueryResource, "rorient/resources/query_resource"
  autoload :CommandResource, "rorient/resources/command_resource"
  autoload :BatchResource, "rorient/resources/batch_resource"

  # client direct queries
  autoload :MetaQueries, "rorient/query/meta_queries"
  autoload :GraphQueries, "rorient/query/graph_queries"

  # query maker
  autoload :Query, "rorient/query/query"
  Query.autoload :Error, "rorient/query/error"
  Query.autoload :Util, "rorient/query/util"
  Query.autoload :Quoting, "rorient/query/quoting"
  Query.autoload :Traverse, "rorient/query/traverse"
  Query.autoload :Select, "rorient/query/select"
  Query.autoload :Insert, "rorient/query/insert"
  Query.autoload :Create, "rorient/query/create"
  Query.autoload :Update, "rorient/query/update"
  Query.autoload :SelectExpand, "rorient/query/select_expand"
  Query.autoload :Match, "rorient/query/match"
  Query.autoload :Where, "rorient/query/where"

  # HTTP API Class to deal with OrientDB errors
  autoload :ErrorHandlingResourceable, "rorient/error_handling_resourceable"

  # Migrations
  autoload :Migrations, "rorient/migrations"

  # Errors
  
  Error = Class.new(StandardError)
  FailedCreate = Class.new(Rorient::Error)
  FailedUpdate = Class.new(Rorient::Error)
  Query::Error = Class.new(Rorient::Error)

  class RateLimitReached < Rorient::Error
    attr_accessor :reset_at
    attr_writer :limit, :remaining

    def limit
      @limit.to_i if @limit
    end

    def remaining
      @remaining.to_i if @remaining
    end
  end

  def self.connect(server:, user:, password:, db_name:)
    Rorient::Client.new(server: server, user: user, password: password, scope:{database: db_name})
  end
end

# need to call this or it will not find it in the
# self.Model method!
Rorient::Vertex
Rorient::Edge
Rorient::Base
