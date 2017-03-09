module Rorient::Queries
  IsAlreadySelectQuery = Class.new(StandardError) 
  IsAlreadyTraverseQuery = Class.new(StandardError) 

  class Maker
    def select
      raise IsAlreadyTraverseQuery if @is_traverse
      @is_select = true
      Rorient::Queries::Maker::Select.new
    end

    def traverse
      raise IsAlreadySelectQuery if @is_select
      Rorient::Queries::Maker::Traverse.new
    end
  end
end
