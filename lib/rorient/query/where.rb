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
    case 
    when args.empty?; @conditions << "#{name}"
    when args.first.nil?; @conditions << "#{name} IS NULL"
    when args.first == true; @conditions << "#{name} IS NOT NULL"
    when args.count > 1
      case args.first
      when :like; @conditions << "#{name} LIKE '%#{args.last}%'"
      else @conditions << "#{name} IN [#{args.map{|a| "'#{a}'"}.join(",")}]"
      end
    else 
      param = [String, Symbol].include?(args.first.class) ? "'#{args.first}'" : args.first 
      @conditions << "#{name} = #{param}"
    end
    # args.empty? ? @conditions << "#{name}" : @conditions << "#{name} = #{args.first}"
    self
  end
end
