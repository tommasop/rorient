class Rorient::Query::Insert
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :db, :_into, :_where, :_set, :_from

  def initialize(db)
    @db = db 
    @_into = nil
    @_fields = []
    @_from = nil 
    @_set = []
  end

  def into(args)
    @_into = "INTO #{args}"
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

  def subquery(type: "select")
    bark("SUBQUERY already initialized for current query") if @subquery
    @subquery ||= Rorient::Query.send(type, db)
  end

  def osql
    q = ["INSERT"]
    q << _into  << _set << _from
    q.compact.flatten.join(" ")
  end

  def execute
    results = raw.map!{|i| i[:@class].constantize.new(i)}
    # results.size > 1 ? results : results.first
  end

  def raw
    results = db.command.execute(command_text: URI.encode(osql, " '%,:#()[]"))[:result]
    @_fields = []     
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

