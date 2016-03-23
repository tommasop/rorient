require 'rorient/version'
require 'resource_kit'
require 'oj'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'securerandom'

# Always parse string keys into symbols
Oj.default_options = {:symbol_keys => true}

module Rorient
  autoload :Client, 'rorient/client'
  
  # Base Model
  autoload :Rid, 'rorient/models/rid'
  autoload :Model, 'rorient/models/model'

  # Resources
  #autoload :Server, 'rorient/resources/server'
  autoload :DocumentResource, 'rorient/resources/document_resource'
  autoload :OClassResource, 'rorient/resources/oclass_resource'
  autoload :QueryResource, 'rorient/resources/query_resource'
  autoload :CommandResource, 'rorient/resources/command_resource'
  autoload :BatchResource, 'rorient/resources/batch_resource'

  # Utils
  autoload :ErrorHandlingResourceable, 'rorient/error_handling_resourceable'

  # Migrations
  autoload :Migrations, 'rorient/migrations'

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

  def self.connect(db_name:)
    Rorient::Client.new(scope:{database: db_name})
  end
end
