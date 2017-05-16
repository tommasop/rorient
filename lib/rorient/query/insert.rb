class Rorient::Query::Insert
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :db, :_into, :_where, :_set

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

  def from(type: "select")
    bark("FROM already initialized for current query") if @_from
    @subquery ||= Rorient::Query.send(type, db)
    self
  end

  def _from
    @subquery ? @_from = "FROM (" << @subquery.osql << ")" : @_from
  end
  
  def set(args, &block)
    if block
      block.arity < 1 ? instance_eval(&block) : block.call(self)
    else
      @_set = "CONTENT #{Oj.dump(args, mode: :compat)}"
    end
    self
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
    param = [String, Symbol].include?(args.first.class) ? "'#{args.first}'" : args.first 
    @_set << "#{name} = #{param}"
    self
  end
end

