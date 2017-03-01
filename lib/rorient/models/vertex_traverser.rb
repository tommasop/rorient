module Rorient
  class VertexTraverser
    include Enumerable

    attr_accessor :order, :uniqueness, :depth, :prune, :filter, :edges

    def initialize(from, types = nil, dir = "all" )
      @from  = from
      @order = "depth first"
      @uniqueness = "none"
      @edges = Array.new
      types.each do |type|
        @edges << {"type" => type.to_s, "direction" => dir.to_s }
      end unless types.nil?
    end
  end
end
