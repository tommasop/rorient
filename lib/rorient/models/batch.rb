module Rorient
  class Batch
    def initialize(statements: [])
      @statements = statements
    end

    def generate_hash
      { transaction: false, operations: [ { type: "script", language: "sql", script: @statements } ] }
    end
  end
end
