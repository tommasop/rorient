module Rorient
  module VertexGraph
    def outE(types = nil)
      Rorient::NodesRetriever.new(self, "E", :out, types)
    end

    def inE(types = nil)
      Rorient::NodesRetriever.new(self, "E", :in, types)
    end

    def bothE(types = nil)
      Rorient::NodesRetriever.new(self, "E", :both, types)
    end

    def out(types = nil)
      Rorient::NodesRetriever.new(self, "", :out, types)
    end

    def in(types = nil)
      Rorient::NodesRetriever.new(self, "", :in, types)
    end

    def both(types = nil)
      Rorient::NodesRetriever.new(self, "", :both, types)
    end

    def traverseI(depth = nil, strategy = nil)
      Rorient::NodesRetriever.new(self, "T", :in).depth(depth).strategy(strategy)
    end
    
    def traverseO(depth = nil, strategy = nil)
      Rorient::NodesRetriever.new(self, "T", :out).depth(depth).strategy(strategy)
    end
  end
end
