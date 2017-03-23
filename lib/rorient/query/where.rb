class Rorient::Query::Where
  include Enumerable
  include Rorient::Query::Util
  
  attr_reader :conditions, :operators

  def initialize(*args, &block)
    @conditions = []
    if block
      self.argument = case block.arity
                      when 0 then instance_eval(&block)
                      else        block.call(self)
                      end
    end
  end

  def osql
    @conditions.flatten.compact.join(" ")
  end

  def method_missing(name, *args)
    return if name =~ /argument/
    args.empty? ? @conditions << "#{name}" : @conditions << "#{name} = #{args.first}"
    self
  end
end

