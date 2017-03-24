class Rorient::Query::Where
  include Enumerable
  include Rorient::Query::Util

  # Whitelist of OrientDB usable methods
  ITEMS = [:column, :any, :all]
  RECORD_ATTRIBUTES = [:@this, :@rid, :@class, :@version, :@size, :@type]
  CONDITIONAL_OPERATORS = [:"=", :like, :<, :<=, :>, :>=, :"<>", :between, :is, :instanceof, :in, :contains, :containsall, 
                 :containskey, :containsvalue, :containstext, :matches, :traverse]
  LOGICAL_OPERATORS = [:and, :or, :not]
  MATHEMATICAL_OPERATORS = [:+, :-, :*, :/, :%] # complex expressions can be evaluated eval("amount * 120/100 - discount")
  VARIABLES = [:$parent, :$current, :$depth, :$path, :$stack, :$history]
  
  
  attr_reader :conditions, :operators

  def initialize(*args, &block)
    @conditions = []
    block.arity < 1 ? instance_eval(&block) : block.call(self)
  end

  def osql
    @conditions.flatten.compact.join(" ")
  end

  def method_missing(name, *args)
    args.empty? ? @conditions << "#{name}" : @conditions << "#{name} = #{args.first}"
    self
  end
end

