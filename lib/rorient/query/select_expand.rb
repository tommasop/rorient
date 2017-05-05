class Rorient::Query::SelectExpand
  include Enumerable
  include Rorient::Query::Util

  attr_reader :db, :_fields, :_where, :_where_pos, :_limit, :_order

  def initialize(db)
    @db = db 
    @_fields = []
    @_from = nil 
    @_where = []
    @_where_pos = 0
    @_limit = nil
    @_order = nil 
  end

  # I need to know:
  # 1. direction: in | out | both
  # 2. v or e default "" which means in()
  # 3. an edge || vertex class 
  # 4. a named hash of filters achieved with the ruby 2 double splat [**] operator
  def fields(direction, v_or_e = "", type = nil, &block)
    bark("Direction must be one of :in, :out, :both") unless [:in, :out, :both].include?(direction) if direction
    bark("The type must be either and Edge or a Vertex class") unless (type.ancestors & [Rorient::Vertex, Rorient::Edge]).any? if type
    field = "#{direction}#{v_or_e}"
    type ? field << "('#{type}')" : field << "()"
    @_fields << field 
    @_where << nil
    where(&block) if block
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

  def from(args, &block)
    bark("Subquery already initialized as current query FROM") if @subquery
    if args.is_a? Array
      @_from = "FROM [#{args.map{|r| Rorient::Rid.new(rid_obj: r).rid }.compact.join(",")}]" 
    else
      @_from = "FROM #{args}"
    end
    self
  end

  def _from
    @subquery ? @_from = "FROM (" << @subquery.osql << ")" : @_from
  end

  def where(*args, &block)
    bark("The query can have as many wheres as its traversal levels") if _where_pos == _fields.count
    @_where[@_where_pos] =  Rorient::Query::Where.new(args, &block).osql 
    @_where_pos += 1
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
  
  def subquery(type: "select")
    bark("FROM already initialized for current query") if @subquery
    @subquery ||= Rorient::Query.send(type, db)
  end

  def osql
    inject_where
    q = ["SELECT EXPAND("] << _fields.join(".") << ")" << _from << _limit << _order << "/-1"
    q.compact.flatten.join(" ")
  end

  def execute
    results = raw.map!{|i| i[:@class].constantize.new(i)}
    # results.size > 1 ? results : results.first
  end

  def raw
    results = db.query.execute(query_text: URI.encode(osql, " ,:#()[]"))[:result]
    @_fields = []     
    results
  end
  
  private
  
  def inject_where
    @_where.each_with_index do |filters, field_pos|
      filters ? @_fields[field_pos] << "[ #{filters} ]" : @_fields[field_pos] 
    end
  end
end

