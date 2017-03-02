module Rorient
  module GraphQueries
  
    def get_vertex_edges(rid, direction = nil, types = nil)
      types = types ? types.map{|type| "'" + type + "'"}.join(",") : ""
      query.execute(query_text: URI.encode("SELECT EXPAND(#{direction || "both"}E(#{types})) FROM #{rid}"))[:result]
    end
    
    def get_vertex_vertexes(rid, direction = nil, types = nil)
      types = types ? types.map{|type| "'" + type + "'"}.join(",") : ""
      query.execute(query_text: URI.encode("SELECT EXPAND(#{direction || "both"}(#{types})) FROM #{rid}"))[:result]
    end

  end
end
