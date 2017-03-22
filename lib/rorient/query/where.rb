class Rorient::Query::Where
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :conditions, :operators

  def initialize(**args)
    @conditions = {}
    @operators = []
  end

  def osql
    q = ["SELECT EXPAND("] << _fields.join(".") << ")" << _from << _limit << _order << "/-1"
    q.compact.flatten.join(" ")
  end
end

