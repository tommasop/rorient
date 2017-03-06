module Rorient
  class Edge < Base
    # Syntactic sugar for Edge.new(atts).save
    def self.create(from_vertex, to_vertex, atts = {})
      atts[:out] = Rid.new(rid_obj: from_vertex).rid
      atts[:in] = Rid.new(rid_obj: to_vertex).rid
      new(atts).save
    end

    def outV(types = nil)
      Rorient::NodesRetriever.new(self, "", :out, types)
    end

    def inV(types = nil)
      Rorient::NodesRetriever.new(self, "", :in, types)
    end

    def bothV(types = nil)
      Rorient::NodesRetriever.new(self, "", :both, types)
    end
  end

  #   class Comment < Rorient::Edge(DBCLIENT)
  #   this sets the instance variable @odb to the
  #   OrientDB Database 
  def self.Edge(source)
    if source.is_a?(Rorient::Client)
      c = Class.new(Rorient::Edge)
      c.odb = source
      c
    else
      raise(Error, "No OrientDB connection associated with #{self}")
    end
  end
end
