module Rorient
  class Rid
    def self.get(atts={})
      puts atts
      puts atts.keys
      puts atts.keys.include?(:rid)
      case 
      when atts.keys.include?(:@rid)
        return atts[:@rid].gsub!("#",'')
      when atts.keys.include?(:rid)
        puts atts[:rid]
        return atts[:rid].gsub!("#",'')
      default
        return nil
      end
    end
  end
end
