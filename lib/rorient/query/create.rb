class Rorient::Query::Create
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :db, :type,:_o_class, :_set, :_from

  def initialize(db, type = "VERTEX")
    @db = db 
    bark("Type must be either VERTEX or EDGE") if !["VERTEX", "EDGE"].include?(type)
    @type = type
    @o_class = nil
    @_from = nil 
    @_set = []
  end

  def o_class(args)
    bark("The argument must be an OrientDB class") unless args.is_a?(Class)
    bark("The OrientDB class must be either and Edge or a Vertex") unless (args.ancestors & [Rorient::Vertex, Rorient::Edge]).any?
    @_o_class = "#{args}"
    self
  end

  def from(from_select)
    bark("FROM already initialized for current query") if @_from
    bark("FROM must be a select") unless from_select.is_a? Rorient::Query::Select
    @_from = "FROM (" << from_select.osql(false) << ")" 
    self
  end

  def set(args = nil, &block)
    if block
      block.arity < 1 ? instance_eval(&block) : block.call(self)
    else
      @_set = "CONTENT #{Oj.dump(args, mode: :compat)}"
    end
    self
  end

  def _set
    if @_set.is_a? String
      @_set
    else
      ["SET"] << @_set
    end
  end

  def osql
    q = ["CREATE"]
    q << type << _o_class  << _set << _from
    q.compact.flatten.join(" ")
  end

  def execute
    results = raw.map!{|i| i[:@class].constantize.new(i)}
    # results.size > 1 ? results : results.first
  end

  def raw
    results = db.command.execute(command_text: URI.encode(osql, " '%,:#()[]"))[:result]
    @_set = []     
    @_from = nil
    results
  end

  def method_missing(name, *args)
    if args.first.is_a? Rorient::Query::Select
      param = "(#{args.first.osql(false)})"
    else
      param = [String, Symbol].include?(args.first.class) ? "'#{args.first}'" : args.first 
    end
    @_set << "#{name} = #{param}"
    self
  end
end

