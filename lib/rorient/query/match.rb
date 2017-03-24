class Rorient::Query::Match
  include Enumerable
  include Rorient::Query::Util

  attr_reader :db, :_start, :_start_where, :_fields, :_where, :_where_pos, :_ret, :_ret_pos, :_limit

  def initialize(db)
    @db = db 
    @_start = nil
    @_start_where = nil
    @_fields = []
    @_where = []
    @_where_pos = 0
    @_ret = []
    @_ret_pos = 0
    @_limit = nil
    @_order = nil 
  end

  def start(start, &block)
    bark("The type must be either and Edge or a Vertex class") unless (start.ancestors & [Rorient::Vertex, Rorient::Edge]).any? if start.is_a? Class
    @_start = "{class: #{start.name}, as: #{start.name.underscore}}" 
    @_start_where = Rorient::Query::Where.new(&block).osql if block
    self
  end
  alias_method :from, :start

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
    bark("The query can have as many wheres as its traversal levels") if _where_pos == _fields.count
    @_where[@_where_pos] =  Rorient::Query::Where.new(args, &block).osql 
    @_where_pos += 1
    self
  end

  def ret(*args)
    bark("The query can have as many returns as its traversal levels") if _ret_pos > _fields.count
    p @_ret
    @_ret[@_ret_pos] = args
    p @_ret
    @_ret_pos += 1
    self
  end

  def limit(record_number = 20)
    @_limit = "LIMIT #{record_number}"
    self
  end

  def osql
    q = ["MATCH"] << _start << _fields.join(".") << _ret << _limit << "/-1"
    q.compact.flatten.join(" ")
  end

  def execute
    results = db.query.execute(query_text: URI.encode(osql, " ,:#()[]"))[:result]
    @_fields, @_where, @_ret = []
    @_where_pos, @_ret_pos = 0
    results
  end
end

