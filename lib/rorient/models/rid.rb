module Rorient
  class Rid
    def self.get(atts={})
      case 
      when atts.class == String
        atts.gsub("#",'')
      when atts.keys.include?(:@rid)
        atts[:@rid].gsub("#",'')
      when atts.keys.include?(:rid)
        atts[:rid].gsub("#",'')
      else
        nil
      end
    end
  end
end
