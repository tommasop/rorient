# TODO: review because not working probably not
# useful use MATCH instead
class Rorient::Query::Traverse
  include Enumerable
  include Rorient::Query::Util
  
  class SubqueryAlreadyInitialized < StandardError; end
  class FromAlreadyInitialized < StandardError; end
  class MaxdepthAlreadyInitialized < StandardError; end
  class LimitAlreadyInitialized < StandardError; end

  attr_reader :_fields, :_maxdepth, :_while, :_limit, :_strategy

  def initialize
    @query = ["TRAVERSE"]
    @_fields = []
    @_from = ["FROM"]
    @_maxdepth = nil
    @_while = {}
    @_limit = nil
    @_strategy = nil 
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

  def maxdepth(depth_level = 0)
    raise LimitAlreadyInitialized if @_limit
    @_maxdepth = "MAXDEPTH #{depth_level}"
    self
  end
  
  def limit(record_number = 20)
    raise MaxdepthAlreadyInitialized if @_maxdepth
    @_limit = "LIMIT #{record_number}"
    self
  end

  def strategy(type = "DEPTH_FIRST")
    @_strategy = "STRATEGY #{type}"
    self
  end
  
  def subquery(type: "Select")
    raise SubqueryAlreadyInitialized if @subquery
    raise FromAlreadyInitialized if !@_from.empty?
    @subquery ||= "Rorient::Queries::Maker::#{type}".constantize.new
  end

  def query
    @query << _fields << _from << _maxdepth << _while << _limit << _strategy << "/-1"
    @query.compact.flatten.join(" ")
  end
end

