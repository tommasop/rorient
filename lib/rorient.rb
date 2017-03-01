require "rorient/version"
require "resource_kit"
require "oj"
require "active_support/inflector"
require "active_support/core_ext/object/blank"
require "securerandom"

# Always parse string keys into symbols
Oj.default_options = {:symbol_keys => true}

module Rorient
  autoload :Client, "rorient/client"
  
  # Utils to deal with OrientDB rids and batches
  autoload :Rid, "rorient/utils/rid"
  autoload :Batch, "rorient/utils/batch"

  # Data modeling classes
  autoload :Model, "rorient/models/model"
  autoload :Vertex, "rorient/models/vertex"
  autoload :VertexEdge, "rorient/models/vertex_edge"
  autoload :VertexTraverser, "rorient/models/vertex_traverser"
  autoload :Edge, "rorient/models/edge"
  autoload :EdgeTraverser, "rorient/models/edge_traverser"

  # OrientDB HTTP API Endpoints
  #autoload :Server, "rorient/resources/server"
  autoload :DocumentResource, "rorient/resources/document_resource"
  autoload :OClassResource, "rorient/resources/oclass_resource"
  autoload :OPropertyResource, "rorient/resources/oproperty_resource"
  autoload :QueryResource, "rorient/resources/query_resource"
  autoload :CommandResource, "rorient/resources/command_resource"
  autoload :BatchResource, "rorient/resources/batch_resource"

  # HTTP API Class to deal with OrientDB errors
  autoload :ErrorHandlingResourceable, "rorient/error_handling_resourceable"

  # Migrations
  autoload :Migrations, "rorient/migrations"

  # Errors
  
  Error = Class.new(StandardError)
  FailedCreate = Class.new(Rorient::Error)
  FailedUpdate = Class.new(Rorient::Error)

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
