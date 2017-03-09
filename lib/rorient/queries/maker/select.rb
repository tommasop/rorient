class Rorient::Queries::Maker::Select
  include Enumerable
  include Rorient::Queries::Maker::Util

  def initialize
    @query = ["SELECT"]
    @criteria = {fields: [], from: [], where: {}, limit: nil, order: nil}
  end

  def fields(*args)
    criteria[:fields] = criteria[:fields] + parse_fields(args)
    self
  end

  def from(*args)
    criteria[:from] = criteria[:from] + parse_from(args.count == 1 ? args[0] : args)
    self
  end

  def nested(arg)
    raise WrongNestedQuery unless [Rorient::Queries::Maker::Select, Rorient::Queries::Maker::Traverse].include?(arg.class)
    from(arg.query)
  end

  def maxdepth(arg)
    raise WrongA
  end

end
