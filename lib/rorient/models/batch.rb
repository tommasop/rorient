module Rorient
  class Batch
    def self.from_string(statement:, with_separator:)
      if statement.is_a? String
        self.new(statements: statement.split(with_separator))
      else
        raise Rorient::Error("statement must be a String")
      end
    end

    def initialize(statements: [])
      @statements = statements
    end

    def generate_hash(with_transaction: false)
      { transaction: with_transaction, operations: [ { type: "script", language: "sql", script: @statements } ] }
    end
  end
end
