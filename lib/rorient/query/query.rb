module Rorient
  class Query
    IsAlreadySelectQuery = Class.new(StandardError) 
    IsAlreadyTraverseQuery = Class.new(StandardError) 

    def self.select(db)
      Rorient::Query::Select.new(db)
    end

    def self.select_expand(db)
      Rorient::Query::SelectExpand.new(db)
    end

    def self.traverse(db)
      Rorient::Query::Traverse.new(db)
    end
    
    def self.match(db)
      Rorient::Query::Match.new(db)
    end
  end
end
