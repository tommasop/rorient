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
  end
end
