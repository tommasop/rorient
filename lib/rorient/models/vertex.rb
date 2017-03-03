module Rorient
  class Vertex < Base

    #def self.named_vertexes(association_class, association_type = :one2many)
    #  association_name, direction = Rorient::AssociationData.from(association_class, association_type)
    #  attr_accessor association_name

    #  define_method association_name do
    #    self.send(direction, association_class)
    #  end

    #  define_method "#{association_name}=" do | vertex |
    #    if vertex.class == association_class.constantize
    #      self.send(association_name) << edge_class.constantize.create(self.rid, vertex.rid)
    #      self.send(association_name)
    #    else
    #      raise DifferentVertexClassError, "Expected a vertex of type #{vertex_class} received #{vertex.class} instead."
    #    end
    #  end
    #end
    #
    #def self.named_edges(name, direction = :both, rel_type = "ONE2MANY")

    #end
    
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

    def traverseI(types = nil, depth = nil, strategy = nil)
      Rorient::NodesRetriever.new(self, "T", :in, types).depth(depth).strategy(strategy)
    end
    
    def traverseO(types = nil, depth = nil, strategy = nil)
      Rorient::NodesRetriever.new(self, "T", :out, types).depth(depth).strategy(strategy)
    end
  end
  
  #   class Comment < Rorient::Vertex(DBCLIENT)
  #   this sets the instance variable @orientdb to the
  #   OrientDB Database 
  def self.Vertex(source)
    if source.is_a?(Rorient::Client)
      c = Class.new(Rorient::Vertex)
      c.odb = source
      c
    else
      raise(Error, "No OrientDB connection associated with #{self}")
    end
  end
end
