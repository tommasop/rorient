class Rorient::Query::Match
  include Enumerable
  include Rorient::Query::Util
  
  class WrongOrderDir < StandardError; end
  class LimitAlreadyInitialized < StandardError; end

  attr_reader :db, :_start, :_fields, :_where, :_limit, :_order

  def initialize(db)
    @db = db 
    @_start = nil
    @_fields = []
    @_where = {}
    @_limit = nil
    @_order = nil 
  end

  def start(start = "V", where: {})
    fields(:start, class: start, as: start.downcase, where: where)
    self
  end

  # I need to know:
  # 1. direction: in | out | both
  # 2. v or e default "" which means in()
  # 3. an edge || vertex class 
  # 4. a named hash of filters achieved with the ruby 2 double splat [**] operator
  def fields(direction = nil, v_or_e = "", type = nil, **args)
    @_fields[0] = fields(args) if direction.eql?(:start)
    field = ""
    if direction
      field = "#{direction}#{v_or_e}"
      type ? field << "('#{type}')" : field << "()"
    end
    field << "{#{args.map{|k,v| "#{k}: #{v}"}.join(",")}}" if !args.empty?
    @_fields << field if !field.empty? 
    self
  end

  def in(v_or_e = "", type = nil, **args)
    fields(:in, v_or_e, type, args)
  end
  
  def out(v_or_e = "", type = nil, **args)
    fields(:out, v_or_e, type, args)
  end

  def both(v_or_e = "", type = nil, **args)
    fields(:both, v_or_e, type, args)
  end

 # def where(*args)
 #   @_where = parse_args(args) 
 #   self
 # end

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

