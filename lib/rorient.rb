require 'rorient/version'
require 'resource_kit'
require 'oj'
require 'active_support/inflector'

# Always parse string keys into symbols
#Oj.default_options = {:symbol_keys => true}

module Rorient
  autoload :Client, 'rorient/client'

  # Resources
  #autoload :Server, 'rorient/resources/server'
  autoload :DocumentResource, 'rorient/resources/document_resource'
  autoload :OClassResource, 'rorient/resources/oclass_resource'
  autoload :QueryResource, 'rorient/resources/query_resource'

  # Base Model
  autoload :Model, 'rorient/models/model'

  # Utils
  autoload :ErrorHandlingResourceable, 'rorient/error_handling_resourceable'

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
end
