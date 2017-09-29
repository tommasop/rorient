class Rorient::Query::Update
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :db, :_set, :_where, :_limit, :_upsert

  def initialize(db, oclass)
    @db = db 
    @_set = []
    @_from = oclass 
    @_where = nil
    @_limit = nil
    @_upsert = nil 
  end

  def upsert
    @_upsert = ["UPSERT"]
    self
  end

  def set(args = nil, &block)
    if block
      block.arity < 1 ? instance_eval(&block) : block.call(self)
    else
      @_set = "MERGE #{Oj.dump(args, mode: :compat)}"
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

  def fields(*args)
    @_fields = @_fields + parse_args(args)
    self
  end

  def _fields
    @_fields.join(",")
  end

  def where(*args, &block)
    @_where  =  Rorient::Query::Where.new(args, &block).osql 
    self
  end

  def _where
   @_where ? "WHERE " << @_where : @_where
  end

  def limit(record_number = 20)
    @_limit = "LIMIT #{record_number}"
    self
  end

  def order(dir = "ASC", *args)
    bark("Wrong order DIR only ASC | DESC possible") if ! ["ASC", "DESC"].include?(dir)
    @_order = "ORDER BY #{parse_args(args).join(",")} #{dir}"
    self
  end
  
  def subquery(type: "select")
    bark("FROM already initialized for current query") if @subquery
    @subquery ||= Rorient::Query.send(type, db)
  end

  def osql
    bark("UPSERT needs a WHERE clause") if _upsert && !_where
    q = ["UPDATE"]
    q << _from << _upsert << _where << _limit 
    q.compact.flatten.join(" ")
  end

  def execute
    results = raw.map!{|i| i[:@class].constantize.new(i)}
    # results.size > 1 ? results : results.first
  end

  def raw
    results = db.command.execute(command_text: URI.encode(osql, " '%,:#()[]"))[:result]
    @_set = []     
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

