class Rorient::Queries::Maker::Select
  include Enumerable
  include Rorient::Queries::Maker::Util
  
  class SubqueryAlreadyInitialized < StandardError; end
  class FromAlreadyInitialized < StandardError; end
  class WrongOrderDir < StandardError; end
  class LimitAlreadyInitialized < StandardError; end

  attr_reader :_fields, :_where, :_limit, :_order

  def initialize
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
    @subquery || @_from
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
    @query << _fields << _from << _while << _limit << _order
    @query.compact.flatten.join(" ")
  end
end

