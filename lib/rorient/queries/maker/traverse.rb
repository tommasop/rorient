class Rorient::Queries::Maker::Traverse
  include Enumerable
  include Rorient::Queries::Maker::Util

  attr_reader :_fields, :_from, :_maxdepth, :_while, :_limit, :_strategy

  def initialize
    @query = ["TRAVERSE"]
    @_fields = []
    @_from = []
    @_maxdepth = nil
    @_while = {}
    @_limit = nil
    @_strategy = nil
  end

  def fields(*args)
    @_fields = @_fields + parse_args(args)
    self
  end

  def from(*args)
    @_from = @_from + parse_args(args)
    self
  end

  def subquery(type: "Select")
    raise SubqueryAlreadyInitialized if @subquery
    raise FromAlreadyInitialized if !@from.empty?
    @subquery ||= "Rorient::Queries::Maker::#{type}".constantize.new
  end

  def query
  end
end

