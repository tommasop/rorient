module Rorient
  class Vertex < Base

    def self.named_vertexes(name, edge_class, direction = :both)
      attr_accessor name

      define_method name do
        self.send(direction, edge_class).to_a
      end

      define_method "#{name}=" do | vertex |
        edge_class.constantize.create(self.rid, vertex.rid)
        self.send(direction, edge_class)
      end
    end

    def self.query(type = "select_expand", &block)
      @query = Rorient::Query.send(type, self.odb).from(self, &block)
    end

    def self.all
      Rorient::NodesRetriever.new(self, "V").get_all
    end
    
    def self.outE(types = nil)
      Rorient::NodesRetriever.new(self, "E", :out, types)
    end

    def self.inE(types = nil)
      Rorient::NodesRetriever.new(self, "E", :in, types)
    end

    def self.bothE(types = nil)
      Rorient::NodesRetriever.new(self, "E", :both, types)
    end

    def self.out(types = nil)
      Rorient::NodesRetriever.new(self, "", :out, types)
    end

    def self.in(types = nil)
      Rorient::NodesRetriever.new(self, "", :in, types)
    end

    def self.both(types = nil)
      Rorient::NodesRetriever.new(self, "", :both, types)
    end

    def self.traverseI(types = nil, depth = nil, strategy = nil)
      Rorient::NodesRetriever.new(self, "T", :in, types).depth(depth).strategy(strategy)
    end
    
    def self.traverseO(types = nil, depth = nil, strategy = nil)
      Rorient::NodesRetriever.new(self, "T", :out, types).depth(depth).strategy(strategy)
    end

    # Persist the vertex attributes
    def save
      features = {
        "@class" => node.name
      }
      
      # We need to update
      if defined?(@rid) && !@rid.nil?
        features["@version"] = @version
        odb.document.update(features.merge(attributes), rid: rid)
        @version += 1
      # we need to create
      else
        @rid = odb.command.execute(command_text: URI.encode("CREATE VERTEX #{node.name} CONTENT #{Oj.dump(attributes, mode: :compat)}"))[:result].first[:@rid]
        @version = 0
      end

      return self
    end

    # Delete the node
    def delete
      odb.command.execute(command_text: URI.encode("DELETE VERTEX #{rid}")) if !new?
      return self
    end
    
    def query(type = "select_expand")
      @query ||= Rorient::Query.send(type, self.class.odb).from(self.rid)
    end

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
