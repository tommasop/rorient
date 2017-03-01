module Rorient
  class Rid
    WrongRidFormat = Class.new(StandardError) 
    NoRidFound = Class.new(StandardError) 

    attr_reader :rid
    
    def initialize(rid_obj:)
      @rid = rid_obj 
      extract_rid_from_hash if rid_obj.is_a? Hash
      @rid = rid_obj.rid if (rid_obj.class.ancestors & [Rorient::Vertex, Rorient::Edge]).any?
      check_rid
    end

    def extract_rid_from_hash
      if @rid.keys.include?(:@rid)
        @rid = @rid[:@rid] 
      elsif @rid.keys.include?(:rid)
        @rid = @rid[:rid] 
      else
        raise NoRidFound 
      end
    end

    def check_rid
      raise WrongRidFormat unless @rid.match(/(#?\d+:{1}\d+)/) 
      @rid.gsub!("#","")
    end
  end
end
