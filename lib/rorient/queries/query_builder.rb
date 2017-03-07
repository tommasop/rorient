module Rorient
  class QueryBuilder
    include Enumerable
    include Rorient::Format
    
    def criteria
      @criteria ||= {}
    end

    def fields(*args)
      criteria[:fields] = criteria[:fields].to_a + parse_fields(args)
      self
    end

    def from(*args)
      criteria[:from] = criteria[:from].to_a + parse_from(args.count == 1 ? args[0] : args)
      self
    end
    
    def traverse(args = {})
      criteria[:traverse] = criteria[:traverse].to_h.merge!(parse_traverse(args))
    end
  end
end
