module Rorient
  class NodesRetriever
    include Enumerable

    attr_reader :from, :odb, :v_or_e, :direction, :o_classes

    def initialize(from, v_or_e = "V", direction = :both, o_classes = nil)
      @from = from.is_a?(Class) ? from.name : from.rid
      @odb = from.is_a?(Class) ? from.odb : from.class.odb
      @v_or_e = v_or_e
      @direction = direction
      @o_classes = o_classes ? [o_classes].flatten : nil
      @depth = nil
      @strategy = nil
      @get_all = nil
    end

    def depth(level = nil)
      @depth = level
      self
    end
    
    def strategy(type = nil)
      @strategy = type
      self
    end

    def get_all
      @get_all = true
      self
    end

    def each
      iterator.map do |i| 
        node = i[:@class].constantize.new(i)
        yield node 
      end
    end

    def iterator
      return odb.get_all(v_or_e, from) if @get_all
      if v_or_e == "T"
        odb.get_traverse(from, direction, o_classes, @depth, @strategy)
      else
        odb.get_nodes(from, "#{direction}#{v_or_e}", o_classes)
      end
    end
  end
end
