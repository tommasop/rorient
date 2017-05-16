class Rorient::Query::Select
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :db, :_fields, :_where, :_limit, :_order

  def initialize(db)
    @db = db 
    @_fields = []
    @_from = nil 
    @_where = nil
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

  def from(args, &block)
    if args.is_a? Array
      @_from = "FROM [#{args.map{|r| Rorient::Rid.new(rid_obj: r).rid }.compact.join(",")}]" 
    else
      @_from = "FROM #{args}"
    end
    where(&block) if block
    self
  end

  def _from
    @subquery ? @_from = "FROM (" << @subquery.osql << ")" : @_from
  end

  def where(*args, &block)
    @_where  =  Rorient::Query::Where.new(args, &block).osql 
    self
  end

  def _where
   "WHERE " << @_where
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

  def osql(all = true)
    q = ["SELECT"]
    q << _fields << _from << _where << _limit << _order
    q << "/-1" if all
    q.compact.flatten.join(" ")
  end

  def execute
    results = raw.map!{|i| i[:@class].constantize.new(i)}
    # results.size > 1 ? results : results.first
  end

  def raw
    results = db.query.execute(query_text: URI.encode(osql, " '%,:#()[]"))[:result]
    @_fields = []     
    results
  end
end

