module Rorient
  module EdgeGraph
    def outV(types = nil)
      Rorient::NodesRetriever.new(self, "", :out, types)
    end

    def inV(types = nil)
      Rorient::NodesRetriever.new(self, "", :in, types)
    end

    def both(types = nil)
      Rorient::NodesRetriever.new(self, "", :both, types)
    end
  end
end
