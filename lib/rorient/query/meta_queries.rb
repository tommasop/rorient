module Rorient
  module MetaQueries
    def table_exists?(table_name)
      !oclass.find(class_name: table_name).nil?
    end

    def create_table(table_name)
      oclass.create(class_name: table_name)
    end
    
    def delete_table(table_name)
      oclass.delete(class_name: table_name)
    end
  
    def get_attributes(o_class)
      oclass.find(class_name: o_class)[:properties]
    end
    
    def get_all(root_class, class_name)
      query.execute(query_text: URI.encode("SELECT FROM #{root_class} WHERE @class = '#{class_name}'/-1"))[:result]
    end
  end
end
