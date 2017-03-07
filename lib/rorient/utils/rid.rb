module Rorient
  class Rid
    WrongRidFormat = Class.new(StandardError) 
    NoRidFound = Class.new(StandardError) 

    def initialize(rid_obj:)
      @rid = rid_obj 
      extract_rid_from_hash if rid_obj.is_a? Hash
      @rid = rid_obj.rid if (rid_obj.class.ancestors & [Rorient::Vertex, Rorient::Edge]).any?
    end

    def rid
      rid! && @rid.gsub!("#","")
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

    def rid?
      !!(@rid.match(/(#?\d+:{1}\d+)/)) 
    end
    
    def rid!
      rid? || raise(WrongRidFormat)  
    end
  end
end