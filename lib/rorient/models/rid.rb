module Rorient
  class Rid
    def self.get(atts={})
      case 
      when atts.include?(:@rid)
        return atts[:@rid].gsub!("#",'')
      when atts.include?(:rid)
        return atts[:rid].gsub!("#",'')
      default
        return nil
      end
    end
  end
end
