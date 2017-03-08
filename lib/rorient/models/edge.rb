module Rorient
  class Edge < Base
    # Syntactic sugar for Edge.new(atts).save
    def self.create(from_vertex, to_vertex, atts = {})
      atts[:out] = Rid.new(rid_obj: from_vertex).rid
      atts[:in] = Rid.new(rid_obj: to_vertex).rid
      new(atts).save
    end

    def self.all
      Rorient::NodesRetriever.new(self, "E").get_all
    end
    
    # Persist the edge attributes
    def save
      features = {
        "@class" => node.name
      }
      
      # We need to update
      if defined?(@rid) && !@rid.nil?
        features["@version"] = @version
        odb.command.execute(command_text: URI.encode("UPDATE EDGE #{rid} MERGE #{Oj.dump(features.merge(attributes), mode: :compat)}"))[:result].first
        @version += 1
      # we need to create
      else
        @rid = odb.command.execute(command_text: URI.encode("CREATE EDGE #{node.name} FROM #{attributes.delete(:out)} TO #{attributes.delete(:in)} CONTENT #{Oj.dump(attributes, mode: :compat)}"))[:result].first[:@rid]
        @version = 0
      end

      return self
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
