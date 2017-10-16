class Rorient::Query::Match
  include Enumerable
  include Rorient::Query::Util

  attr_reader :db, :_fields, :_where, :_where_pos, :_ret, :_ret_pos, :_limit, :_optional, :last_type

  def initialize(db)
    @db = db 
    @_fields = []
    @_where = []
    @_where_pos = 0
    @_ret = []
    @_ret_pos = 0
    @_limit = nil
    @_order = nil 
    @_optional = []
    @last_type = nil
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
    field << "{class: #{type.name}, as: #{unique_as(type.name.underscore)}}"
    @last_type = type.name
    @_fields << field 
    if block
      @_ret << nil && @_where << nil 
      where(&block)
    else
      @_ret << nil && @_where << nil 
      @_ret_pos += 1 && @_where_pos += 1
    end
    self
  end

  def in(type = nil, &block)
    fields(:in, "", type, &block)
  end
  
  def inE(type = nil, &block)
    fields(:in, "E", type, &block)
  end
  
  def inV(type = nil, &block)
    fields(:in, "V", type, &block)
  end
  
  def out(type = nil, &block)
    fields(:out, "", type, &block)
  end
  
  def outE(type = nil, &block)
    fields(:out, "E", type, &block)
  end

  def outV(type = nil, &block)
    fields(:out, "V", type, &block)
  end

  def both(type = nil, &block)
    fields(:both, "", type, &block)
  end
  
  def bothE(type = nil, &block)
    fields(:both, "E", type, &block)
  end

  def bothV(type = nil, &block)
    fields(:both, "V", type, &block)
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
  
  def optional
    @_optional << [@_fields.length - 1, last_type]
    self
  end


  def limit(record_number = 20)
    @_limit = "LIMIT #{record_number}"
    self
  end

  def osql
    inject_opt
    inject_where
    q = ["MATCH"] << @_fields.join(".") << inject_ret << _limit << "/-1"
    q.compact.flatten.join(" ")
  end

  def execute
    results = raw.map!{|i| i[:@class].constantize.new(i)}
    results.size > 1 ? results : results.first
  end

  def raw
    results = db.query.execute(query_text: URI.encode(osql, " ,:#()[]{}"))[:result]
    @_fields, @_where, @_ret = [[],[],[]]
    @_where_pos, @_ret_pos = [0, 0]
    results
  end

  private

  def inject_opt
    _optional.each do | opt |
      if @_fields.length == opt[0] + 1
        @_fields[opt[0]] = (@_fields[opt[0]].split("}") << "optional: true }").join(", ")
      else
        @_fields[opt[0]] = @_fields[opt[0]].split("class: #{opt[1]},").join("") 
      end
    end
  end
  
  def inject_where
    @_where.each_with_index do |filters, field_pos|
      @_fields[field_pos] = (@_fields[field_pos].split("}")<< "where: (#{filters})}").join(", ") if filters
    end
  end

  def inject_ret
    asd_ret = @_ret.compact.each_with_index do |rets, field_pos|
      rets.map{|ret| _fields[field_pos].match(/\bas:\s+\K\w*/)[0] + ".#{ret}" }
    end
    asd_ret.empty? ? "RETURN $pathElements" : "RETURN " << asd_ret.flatten.join(",")
  end

  def unique_as(as_name)
    _fields.map{|f| f.split(as_name).length == 1 ? nil : true }.any? ? as_name.next : as_name  
  end
end

