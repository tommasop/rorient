class Rorient::Query::Where
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :conditions, :operators

  def initialize(**conditions)
    @conditions = {}
    @operators = []
  end

  def osql
    return nil if conditions.empty?
    q = "" 
    q.compact.flatten.join(" ")
  end
end

