module Rorient
  module GraphQueries
  
    def get_nodes(rid, direction = nil, o_classes = nil)
      o_classes = o_classes ? o_classes.map{|o_class| "'" + o_class + "'"}.join(",") : ""
      query.execute(query_text: URI.encode("SELECT EXPAND(#{direction}(#{o_classes})) FROM #{rid}/-1"))[:result]
    end

    def get_traverse(rid, direction = nil, o_classes = nil, depth = nil, strategy = nil)
      depth = depth ? "WHILE $depth <= #{depth}" : ""
      o_classes = o_classes ? o_classes.map{|o_class| "'" + o_class + "'"}.join(",") : ""
      query.execute(query_text: URI.encode("TRAVERSE #{direction || "both"}(#{o_classes}) FROM #{rid} #{depth} STRATEGY #{strategy || "DEPTH_FIRST"}/-1"))[:result]
    end
    
    # Method to check class existence and class being Edge
    def is_edge?(class_name)
      query.execute(query_text: URI.encode("SELECT FROM E WHERE @class = '#{class_name.camelize}'")).present?
    end
  end
end
