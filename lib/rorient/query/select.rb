class Rorient::Query::Select
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :db, :_fields, :_where, :_limit, :_order

  def initialize(db)
    @db = db 
    @_fields = []
    @_from = nil 
    @_where = {}
    @_limit = nil
    @_order = nil 
  end

  def fields(*args)
    @_fields = @_fields + parse_args(args)
    self
  end

  def _fields
    @_fields.join(",")
  end

  def from(*args)
    if args.is_a? Array
      @_from = "FROM [#{args.map{|r| Rorient::Rid.new(rid_obj: r).rid }.compact.join(",")}]" 
    else
      @_from = "FROM #{args}"
    end
    self
  end

  def _from
    @subquery ? @_from << @subquery.query : @_from
  end

  def where(*args)
    @_where = parse_args(args) 
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
  
  def subquery(type: "Select")
    bark("FROM already initialized for current query") if @subquery
    @subquery ||= "Rorient::Query::#{type}".constantize.new
  end

  def osql
    @query << _fields << _from << _where << _limit << _order << "/-1"
    @query.compact.flatten.join(" ")
  end

  def execute
    results = db.query.execute(query_text: URI.encode(osql))
    @_fields = []     
    results
  end
end

