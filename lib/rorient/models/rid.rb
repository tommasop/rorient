module Rorient
  class Rid
    def self.get(atts={})
      puts atts
      case 
      when atts.keys.include?(:@rid)
        return atts[:@rid].gsub!("#",'')
      when atts.keys.include?(:rid)
        return atts[:rid].gsub!("#",'')
      default
        return nil
      end
    end
  end
end
