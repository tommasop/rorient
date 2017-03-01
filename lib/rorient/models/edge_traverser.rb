module Rorient
  class EdgeTraverser
    include Enumerable
    
    def initialize(vertex, types, direction)
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
        rel.start_vertex = Rorient::Vertex.load(rel.start_vertex)
        rel.end_vertex = Rorient::Vertex.load(rel.end_vertex)

        yield rel if match_to_other?(rel)
      end
    end

    def iterator
      Array(@vertex.orientdb.get_vertex_edges(@vertex, @direction, @types))
    end
  end
end
