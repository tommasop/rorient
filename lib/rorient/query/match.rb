class Rorient::Query::Match
  include Enumerable
  include Rorient::Query::Util
  
  class WrongOrderDir < StandardError; end
  class LimitAlreadyInitialized < StandardError; end

  attr_reader :db, :_start, :_fields, :_where, :_limit, :_order

  def initialize(db)
    @db = db 
    @_start = nil
    @_start_where = nil
    @_fields = []
    @_where = []
    @_limit = nil
    @_order = nil 
  end

  def start(start = "V", where: nil)
    @_start = "{class: #{start}, as: #{start.downcase}}" 
    @_start_where = Rorient::Query::Where.new(where).osql
  end

  # I need to know:
  # 1. direction: in | out | both | start
  # 2. v or e default "" which means in()
  # 3. an edge || vertex class 
  # 4. a named hash of filters achieved with the ruby 2 double splat [**] operator
  def fields(direction = nil, v_or_e = "", type = nil, **args)
    field = ""
    if direction
      field = "#{direction}#{v_or_e}"
      type ? field << "('#{type}')" : field << "()"
    end
    field << "{#{args.map{|k,v| "#{k}: #{v}"}.join(",")}}" if !args.empty?
    @_fields << field 
    self
  end

  def in(type = nil, **args)
    fields(:in, "", type, args)
  end
  
  def inE(type = nil, **args)
    fields(:in, "E", type, args)
  end
  
  def inV(type = nil, **args)
    fields(:in, "V", type, args)
  end
  
  def out(type = nil, **args)
    fields(:out, "", type, args)
  end
  
  def outE(type = nil, **args)
    fields(:out, "E", type, args)
  end

  def outV(type = nil, **args)
    fields(:out, "V", type, args)
  end

  def both(type = nil, **args)
    fields(:both, "", type, args)
  end
  
  def bothE(type = nil, **args)
    fields(:both, "E", type, args)
  end

  def bothV(type = nil, **args)
    fields(:both, "V", type, args)
  end

  def where(*args)
    @_where << Rorient::Query::Where.new(args).osql 
    self
  end

  def limit(record_number = 20)
    @_limit = "LIMIT #{record_number}"
    self
  end

  def order(dir = "ASC", *args)
    raise WrongOrderDir if ! ["ASC", "DESC"].include?(dir)
    @_order = "ORDER BY #{parse_args(args).join(",")} #{dir}"
    self
  end
  
  def osql
    q = ["MATCH"] << _fields.join(".") << ")" << _from << _limit << _order << "/-1"
    q.compact.flatten.join(" ")
  end

  def execute
    db.query.execute(query_text: URI.encode(osql, " ,:#()[]"))[:result]
  end
end

