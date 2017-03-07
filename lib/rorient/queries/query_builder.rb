module Rorient
  class QueryBuilder
    include Enumerable
    include Rorient::Format
    
    def criteria
      @criteria ||= {}
    end

    def fields(*args)
      criteria[:fields] = criteria[:fields] + parse_fields(args)
      self
    end

    def from(args)
      criteria[:from] = criteria[:from] + parse_from(args)
      self
    end
    
    def traverse(args)
      criteria[:traverse].merge!(parse_traverse(args))
    end
  end
end
