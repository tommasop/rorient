module Rorient
  module VertexEdge

    DIRECTIONS = ["in", "out", "both"]

    def outgoing(types=nil)
      VertexTraverser.new(self).outgoing(types)
    end

    def incoming(types=nil)
      VertexTraverser.new(self).incoming(types)
    end

    def both(types=nil)
      VertexTraverser.new(self).both(types)
    end

    def rels(*types)
      Rorient::EdgeTraverser.new(self, types, :both)
    end

    def rel(dir, type)
      rel = Rorient::EdgeTraverser.new(self, type, dir)
      rel = rel.first unless rel.empty?
      rel
    end

    def rel?(dir=nil, type=nil)
      if DIRECTIONS.include?(dir.to_s)
        !self.orientdb.get_vertex_edges(self, dir, type).empty? 
      else
        !self.orientdb.get_vertex_edges(self, type, dir).empty? 
      end
    end

  end
end
