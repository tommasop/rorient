class Rorient::Query::SelectExpand
  include Enumerable
  include Rorient::Query::Util
  
  class SubqueryAlreadyInitialized < StandardError; end
  class FromAlreadyInitialized < StandardError; end
  class WrongOrderDir < StandardError; end
  class LimitAlreadyInitialized < StandardError; end

  attr_reader :db, :expand, :_fields, :_where, :_limit, :_order

  def initialize(db)
    @db = db 
    @_fields = []
    @_from = ["FROM"]
    @_where = {}
    @_limit = nil
    @_order = nil 
  end

  # I need to know:
  # 1. v or e default "" which means in()
  # 2. an edge || vertex class 
  # 3. a named hash of filters achieved with the ruby 2 double splat [**] operator
  def in(v_or_e = "", type = nil, **args)
    field = "in#{v_or_e}"
    type ? field << "('#{type}')" : field << "()"
    field << "[#{args.map{|k,v| "#{k}=#{v}"}.join(",")}]" if !args.empty?
    @_fields << field 
    self
  end
  
  def out(v_or_e = "", type = nil, **args)
    field = "out#{v_or_e}"
    type ? field << "('#{type}')" : field << "()"
    field << "[#{args.map{|k,v| "#{k}=#{v}"}.join(",")}]" if !args.empty?
    @_fields << field 
    self
  end

  def both(v_or_e = "", type = nil, **args)
    field = "both#{v_or_e}"
    type ? field << "('#{type}')" : field << "()"
    field << "[#{args.map{|k,v| "#{k}=#{v}"}.join(",")}]" if !args.empty?
    @_fields << field 
    self
  end

  def from(args)
    if args.is_a? Array
      @_from << "[#{args.map{|r| Rorient::Rid.new(rid_obj: r).rid }.join(",")}]" 
    else
      @_from << parse_args(args)
    end
    self
  end

  def _from
    @_from = "(" << @subquery.osql << ")" if @subquery
    @_from
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
  
  def subquery(type: "Select")
    raise SubqueryAlreadyInitialized if @subquery
    raise FromAlreadyInitialized if !@_from.empty?
    @subquery ||= "Rorient::Query::#{type}".constantize.new
  end

  def osql
    q = ["SELECT EXPAND("] << _fields.join(".") << ")" << _from << _limit << _order
    q.compact.flatten.join(" ")
  end

  def execute
    db.query.execute(query_text: URI.encode(osql, " ,:#()[]"))
  end
end

