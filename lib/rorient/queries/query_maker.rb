module Rorient
  class QueryMaker
    include Enumerable
    include Rorient::Format

    def initialize
      @children = []
    end
    
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
      self
    end

    def where(args = {})
      criteria[:conditions] = criteria[:conditions].to_h.merge!(parse_where(args))
      self
    end

    def query
      return nil if criteria.empty?
      if criteria[:traverse]
        if criteria[:fields] || criteria[:from] || criteria[:conditions]
          select_traverse_query
        else
          traverse_query
        end
      else
        select_query
      end
    end

    def traverse_query
      query = ["TRAVERSE"]
      query << criteria[:traverse][:fields] || ["out()"]
      query << (["FROM"] + criteria[:traverse][:from] || ["V"])
      if criteria[:traverse][:while]
        query + ["WHILE"]
        criteria[:traverse][:while].map

    end

    def select_traverse_query
    end

    def select_query
    end
  end
end
