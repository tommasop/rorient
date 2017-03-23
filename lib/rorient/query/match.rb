class Rorient::Query::Match
  include Enumerable
  include Rorient::Query::Util

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

  def start(start, where: nil)
    bark("Direction must be one of :in, :out, :both") unless [:in, :out, :both].include?(direction)
    bark("The type must be either and Edge or a Vertex class") unless (type.ancestors & [Rorient::Vertex, Rorient::Edge]).any?
    @_start = "{class: #{start.name}, as: #{start.name.underscore}" 
    @_start_where = Rorient::Query::Where.new(where).osql
  end

  # I need to know:
  # 1. direction: in | out | both | start
  # 2. v or e default "" which means in()
  # 3. an edge || vertex class 
  # 4. a named hash of filters achieved with the ruby 2 double splat [**] operator
  def fields(direction, v_or_e = "", type)
    bark("Direction must be one of :in, :out, :both") unless [:in, :out, :both].include?(direction)
    bark("The type must be either and Edge or a Vertex class") unless (type.ancestors & [Rorient::Vertex, Rorient::Edge]).any?
    field = "#{direction}#{v_or_e}()"
    field << "{class: #{type.name}, as: #{type.name.underscore}}"
    @_fields << field 
    # for every pattern I create a nil where which
    # can be positionally filled afterwards
    @_where << nil
    self
  end

  def in(type)
    fields(:in, "", type)
  end
  
  def inE(type)
    fields(:in, "E", type)
  end
  
  def inV(type)
    fields(:in, "V", type)
  end
  
  def out(type)
    fields(:out, "", type)
  end
  
  def outE(type)
    fields(:out, "E", type)
  end

  def outV(type)
    fields(:out, "V", type)
  end

  def both(type)
    fields(:both, "", type)
  end
  
  def bothE(type)
    fields(:both, "E", type)
  end

  def bothV(type)
    fields(:both, "V", type)
  end

  def where(*args, &block)
    bark("The query can have as many wheres as its traversal levels") if _where.count == _fields.count
    @_where << Rorient::Query::Where.new(args, &block) 
    self
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
  
  def osql
    q = ["MATCH"] << _fields.join(".") << ")" << _from << _limit << _order << "/-1"
    q.compact.flatten.join(" ")
  end

  def execute
    results = db.query.execute(query_text: URI.encode(osql, " ,:#()[]"))[:result]
    @_fields = []     
    results
  end
end

