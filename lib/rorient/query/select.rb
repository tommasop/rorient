class Rorient::Query::Select
  include Enumerable
  include Rorient::Query::Util
  
  class SubqueryAlreadyInitialized < StandardError; end
  class FromAlreadyInitialized < StandardError; end
  class WrongOrderDir < StandardError; end
  class LimitAlreadyInitialized < StandardError; end

  attr_reader :db, :_fields, :_where, :_limit, :_order

  def initialize(db)
    @db = db 
    @query = ["SELECT"]
    @_fields = []
    @_from = ["FROM"]
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
    @_from << parse_args(args)
    self
  end

  def _from
    @subquery ? @subquery.query : @_from
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
    raise WrongOrderDir if ! ["ASC", "DESC"].include?(dir)
    @_order = "ORDER BY #{parse_args(args).join(",")} #{dir}"
    self
  end
  
  def subquery(type: "Select")
    raise SubqueryAlreadyInitialized if @subquery
    raise FromAlreadyInitialized if !@_from.empty?
    @subquery ||= "Rorient::Queries::Maker::#{type}".constantize.new
  end

  def query
    @query << _fields << _from << _where << _limit << _order
    # @query.compact.flatten.join(" ")
    db.query.execute(query_text: URI.encode(@query.compact.flatten.join(" ")))
  end
end

