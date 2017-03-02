module Rorient
  class EdgeTraverser
    include Enumerable
    
    def initialize(vertex, direction, types)
      @vertex      = vertex
      @types     = [types]
      @direction = direction
    end
    
    def empty?
      first == nil
    end
    
    def each
      iterator.each do |i| 
        rel = Rorient::Edge.new(i)
        #rel.start_vertex = Rorient::Vertex.load!(rel.out)
        #rel.end_vertex = Rorient::Vertex.load!(rel.in)

        yield rel # if match_to_other?(rel)
      end
    end

    def iterator
      Array(@vertex.class.orientdb.get_vertex_edges(@vertex.rid, @direction, @types.flatten))
    end

    def match_to_other?(rel)
      if @to_other.nil?
        true
      elsif @direction == :outgoing
        rel.end_vertex == @to_other
      elsif @direction == :incoming
        rel.start_vertex == @to_other
      else
        rel.start_vertex == @to_other || rel.end_vertex == @to_other
      end
    end

    def to_other(to_other)
      @to_other = to_other
      self
    end

    def delete
      each{ | rel | rel.delete }
    end

    def size
      [*self].size
    end

    def both
      @direction = :both
      self
    end

    def incoming
      @direction = :incoming
      self
    end

    def outgoing
      @direction = :outgoing
      self
    end

  end
end
