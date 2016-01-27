module Rorient
  class Rid
    def self.get(atts={})
      case 
      when atts.keys.include?(:@rid)
        puts ":@rid"
        atts[:@rid].gsub("#",'')
      when atts.keys.include?(:rid)
        puts ":rid"
        atts[:rid].gsub("#",'')
      else
        nil
      end
    end
  end
end
