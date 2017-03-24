class Rorient::Query::Match
  include Enumerable
  include Rorient::Query::Util

  attr_reader :db, :_fields, :_where, :_where_pos, :_ret, :_ret_pos, :_limit

  def initialize(db)
    @db = db 
    @_fields = []
    @_where = []
    @_where_pos = 0
    @_ret = []
    @_ret_pos = 0
    @_limit = nil
    @_order = nil 
  end

  def from(start, &block)
    fields(nil, "", start, &block)
  end

  # I need to know:
  # 1. direction: in | out | both | nil
  # 2. v or e default "" which means in()
  # 3. an edge || vertex class 
  # 4. a block for the where condition { name(:pippo).and.surname(:pluto) }
  def fields(direction, v_or_e = "", type, &block)
    bark("Direction must be one of :in, :out, :both") unless [:in, :out, :both].include?(direction) if direction
    bark("The type must be either and Edge or a Vertex class") unless (type.ancestors & [Rorient::Vertex, Rorient::Edge]).any?
    field = direction ? "#{direction}#{v_or_e}()" : ""
    field << "{class: #{type.name}, as: #{type.name.underscore}}"
    @_fields << field 
    @_ret << nil &&  @_where << nil
    where(&block) if block
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
    bark("The query can have as many returns as its traversal levels") if _ret_pos == _fields.count
    @_ret[@_ret_pos] = args
    @_ret_pos += 1
    self
  end


  def limit(record_number = 20)
    @_limit = "LIMIT #{record_number}"
    self
  end

  def osql
    inject_where
    q = ["MATCH"] << _fields.join(".") << inject_ret << _limit << "/-1"
    q.compact.flatten.join(" ")
  end

  def execute
    results = db.query.execute(query_text: URI.encode(osql, " ,:#()[]"))[:result]
    @_fields, @_where, @_ret = []
    @_where_pos, @_ret_pos = 0
    results
  end

  private
  
  def inject_where
    @_where.each_with_index do |filters, field_pos|
      @_fields[field_pos] = (@_fields[field_pos].split("}")<< "where: (#{filters})}").join(", ") if filters 
    end
  end

  def inject_ret
    @_ret.compact.each_with_index do |rets, field_pos|
      rets.map!{|ret| _fields[field_pos].match(/\bas:\s+\K\w*/)[0] + ".#{ret}" }
    end
    "RETURN " << @_ret.flatten.join(" ")
  end
end

