module Rorient
  class Model
    # This is the instance variable containing the client
    # to OrientDB HTTP API
    @orientdb = nil

    # Raised when metadata are not present
    class MissingMetadata < StandardError; end
    # Raised when trying to create an edge with a different
    # class than that declared in the outs or ins relations
    class DifferentVertexClassError < StandardError; end
    class NoEdgeClassError < StandardError; end  
    
    # The client to connect to the OrientDB HTTP API
    # Use this if you want to do quick ad hoc orientdb commands against the
    # defined connection.
    #
    # Examples:
    #
    #   Rorient.orientdb. 
    #
    def self.orientdb
      @orientdb || raise(Error, "No database associated with #{self}") 
    end

    def self.orientdb=(orientdb)
      @orientdb = orientdb
    end
    
    # Define the orientdb database passed in to the model
    # directly to the inherited class
    def self.inherited(subclass)
      super
      subclass.instance_variable_set(:@orientdb, @orientdb.dup) unless @orientdb.nil?
    end

    def self.mutex
      @@mutex ||= Mutex.new
    end

    def self.synchronize(&block)
      mutex.synchronize(&block)
    end
   
    # Metadata version
    attr_reader :version 

    def self.attribute(name, cast = nil)
      attributes << name unless attributes.include?(name)

      if cast
        define_method(name) do
          cast[@attributes[name]]
        end
      else
        define_method(name) do
          @attributes[name]
        end
      end

      define_method(:"#{name}=") do |value|
        @attributes[name] = value
      end
    end

    # Attributes from object schema if any
    def self.define_attributes
      attributes = orientdb.oclass.find(class_name: self.name)[:properties]
      attributes.each do |attr|
        attribute attr[:name].to_sym
      end
    end
    
    # Method to check class existence and class being Edge
    def self.is_edge?(class_name)
     # orientdb.query.execute(query_text: URI.encode("SELECT FROM ( SELECT expand( classes ) FROM metadata:schema ) WHERE name = '#{class_name.camelize}'")).present? && \
      orientdb.query.execute(query_text: URI.encode("SELECT FROM E WHERE @class = '#{class_name.camelize}'")).present?
    end
    
    # Methods to traverse graphs through relations
    # class MyModel < Rorient::Model
    #   has_many "my_names", vertex_class:"MyOtherModel", edge_class:"has_relations"
    # end
    # 
    # my_model = MyModel.first
    # my_model.my_names.in # gives the MyOtherModel object
    def self.has_many(association_name, vertex_class: , edge_class:)
      if self.is_edge?(edge_class)
        attr_accessor association_name

        define_method association_name do
          orientdb.query.execute(query_text: URI.encode("SELECT EXPAND( OUT(#{edge_class.camelize}) ) FROM #{self.class.to_s} WHERE @rid=#{self.rid}"))[:result]
        end

        define_method "#{association_name}=" do | vertex |
          if vertex.class == vertex_class.constantize
            self.send(edge_class) << orientdb.command.execute(command_text: URI.encode("CREATE EDGE #{edge_class.camelize} from #{self.rid} to #{vertex.rid}"))  
            self.send(edge_class)
          else
            raise DifferentVertexClassError, "Expected a vertex of type #{vertex_class} received #{vertex_class} instead."
          end
        end
      else
        raise NoEdgeClassError, "No Edge class found with name #{edge_class.camelize}"
      end
    end

    # Methods to traverse graphs through relations
    # class MyModel < Rorient::Model
    #   belongs_to "my_name", vertex_class:"MyOtherModel",edge_class:"has_relations"
    # end
    # 
    # my_model = MyModel.first
    # my_model.my_name.out # gives the MyOtherModel object
    def self.belongs_to(association_name, vertex_class:, edge_class:)
      if self.is_edge?(edge_class) 
        attr_accessor association_name

        define_method association_name do
          orientdb.query.execute("SELECT EXPAND( IN(#{edge_class.camelize}) ) FROM #{self.class.to_s} WHERE @rid=#{rid}")[:result]
        end

        define_method "#{association_name}=" do | vertex |
          if vertex.class == vertex_class.constantize
            self.send(edge_class) << orientdb.command.execute(command_text: URI.encode("CREATE EDGE #{edge_class.camelize} from #{vertex.rid} to #{self.rid}"))  
            self.send(edge_class)
          else
            raise DifferentVertexClassError, "Expected a vertex of type #{vertex_class} received #{vertex_class} instead."
          end
        end
      else
        raise NoEdgeClassError, "No Edge class found with name #{edge_class.camelize}"
      end
    end

    # Retrieve a record by ID.
    #
    # Example:
    #
    #   u = User.create
    #   u == User[u.id]
    #   # =>  true
    #
    def self.[](rid)
      if rid && exists?(rid)
        self.new(rid: rid).load!
      end
    end

    # Retrieve a set of models given an array of IDs.
    #
    # Example:
    #
    #   ids = [1, 2, 3]
    #   ids.map(&User)
    #
    # Note: The use of this should be a last resort for your actual
    # application runtime, or for simply debugging in your console. If
    # you care about performance, you should pipeline your reads.
    #
    def self.to_proc
      lambda { |rid| self[rid] }
    end

    # Check if the ID exists within <Model>:all.
    def self.exists?(rid)
      orientdb.document.exists(rid: rid)
    end

    # An Rorient::Set wrapper for Model.key[:all].
    def self.all
      orientdb.query.execute(query_text: URI.encode("SELECT FROM #{self.name}/1000")) # [:result].map{|jo| self.new(jo) } 
    end
   
    def self.first
      self.new(orientdb.query.execute(query_text: URI.encode("SELECT FROM #{self.name} order by @rid/1"))[:result].first)
    end
    
    def self.last
      self.new(orientdb.query.execute(query_text: URI.encode("SELECT FROM #{self.name} order by @rid desc/1"))[:result].first)
    end

    # Syntactic sugar for Model.new(atts).save
    def self.create(atts = {})
      new(atts).save
    end
    
    def self.create_with_uuid(atts = {})
      atts[:uuid] = SecureRandom.uuid 
      new(atts).save
    end

    def self.find_by_uuid(uuid)
      self.new(rid: orientdb.query.execute(query_text: URI.encode("SELECT @rid from #{self.name} WHERE uuid = '#{uuid}'"))[:result][0][:rid].gsub!("#",'')).load!
    end
    
    def self.find(params:)
      query = ["from #{self.name} where"]
      # if I only have the order param strip off where
      query[0].gsub!(" where", "") if params.keys.count == 1 && params["order"]
      # if these three params are present we have a spatial query
      if ["my_lat", "my_long", "zoom"].all?{|spatial_param| params.key? spatial_param}
        distance_in_km = zoom_to_distance_in_km(params["zoom"])
        query.insert(0, "*,$distance") 
        query << "[wgs84_lat,wgs84_long,$spatial] NEAR [#{params["my_lat"]},#{params["my_long"]},{'maxDistance':#{distance_in_km}}]"
      end
      # retrieve all object properties which are the only valid parameters
      attributes = orientdb.oclass.find(class_name: self.name)[:properties].map{|prop| prop[:name]}
      # array intersection only keys that are properties will be left
      query_attributes = (attributes & params.keys)
      # if there is also a spatial query we need to add an AND
      query.insert(3, "AND") if query.length == 3 && query_attributes.present?
      # each property becomes a where property= ecc.
      query_attributes.each_with_index do |attr,i|
        query << "#{attr} = '#{params[attr]}' #{"AND" if i < query_attributes.length - 1}" 
      end
      # adding an order by clause
      query << "order by #{params["order"]}" if params["order"]
      query << "/1000"
      orientdb.query.execute(query_text: URI.encode("SELECT #{query.join(" ")}", /\s|(\*)|(\[)|(\])|(\$)|(\{)|(\})/))
    end

    # method to map google zoom levels to square kilometers
    def self.zoom_to_distance_in_km(zoom)
      case zoom.to_i
      when 20
        return 1 
      when 19
        return 2
      when 18
        return 3
      when 17
        return 4
      when 16
        return 8
      when 15
        return 10
      when 14
        return 12
      when 13
        return 14
      when 12
        return 20
      when 11
        return 24
      when 10
        return 34
      when 9
        return 44
      when 8
        return 60
      when 7
        return 96
      when 6
        return 195
      when 5
        return 390
      when 4
        return 785
      when 3
        return 1575
      when 2
        return 3150
      when 1
        return 6300
      else
        return nil
      end  
    end

    def initialize(atts={})
      @attributes = {}
      @_memo = {}
      @rid = Rid.new(rid_obj: atts).rid 
      @version = atts[:@version] || 0
      update_attributes(_remove_metadata(atts))
    end 

    # Access the RID used to store this model. 
    #
    # Example:
    #
    #   class User < Rorient::Model; end
    #
    #   u = User.create
    #   u.rid
    #   # => 1
    #
    def rid
      @rid
    end

    # Check for equality by doing the following assertions:
    #
    # 1. That the passed model is of the same type.
    # 2. That they represent the same OrientDB key.
    #
    def ==(other)
      other.kind_of?(model) && other.key == key
    rescue MissingRID
      false
    end

    # Preload all the attributes of this model from OrientDB. Used
    # internally by `Model::[]`.
    def load!
      if ! new?
        attributes = orientdb.document.find(rid: rid)
        @version = attributes[:@version]
        update_attributes(_remove_metadata(attributes)) 
      end
      return self
    end

    # Read an attribute remotely from OrientDB. Useful if you want to get
    # the most recent value of the attribute and not rely on locally
    # cached value.
    #
    # Example:
    #
    #   User.create(:name => "A")
    #
    #   Session 1     |    Session 2
    #   --------------|------------------------
    #   u = User[1]   |    u = User[1]
    #   u.name = "B"  |
    #   u.save        |
    #                 |    u.name == "A"
    #                 |    u.get(:name) == "B"
    #
    def get(att)
      @attributes[att] = orientdb.query.execute(query_text: URI.encode("SELECT #{att} FROM #{self.class.to_s} WHERE @rid = #{rid}"))[:result][att]
    end


    # Returns +true+ if the model is not persisted. Otherwise, returns +false+.
    def new?
      !defined?(@rid)
    end
    
    # Returns a hash of the attributes with their names as keys
    # and the values of the attributes as values. It doesn't
    # include the ID of the model.
    def attributes
      @attributes
    end

    def to_hash
      attrs = {}
      attrs[:rid] = rid unless new?

      return attrs
    end

    # Persist the model attributes
    def save
      features = {
        "@class" => model.name
      }
      
      # We need to update
      if defined?(@rid) && !@rid.nil?
        features["@version"] = @version
        puts features.merge(attributes)
        orientdb.document.update(features.merge(attributes), rid: rid)
        @version += 1
      # we need to create
      else
        @rid = orientdb.document.create(features.merge(attributes))[:@rid]
        @version = 0
      end

      return self
    end

    # Delete the model
    def delete
      orientdb.document.delete(rid: rid) if !new? 

      return self
    end

    # Update the model attributes and call save.
    #
    # Example:
    #
    #   User[1].update(:name => "John")
    #
    #   # It's the same as:
    #
    #   u = User[1]
    #   u.update_attributes(:name => "John")
    #   u.save
    #
    def update(attributes)
      update_attributes(attributes)
      save
    end

    # Write the dictionary of key-value pairs to the model.
    def update_attributes(atts)
      atts.each { |att, val| 
        self.class.__send__(:attribute, att.to_sym) unless methods.include?(att.to_sym)
        send(:"#{att}=", val) 
      }
    end

    protected
    
    def self.attributes
      @attributes ||= []
    end

    attr_writer :id

    def model
      self.class
    end

    def orientdb
      model.orientdb
    end

    def _remove_metadata(atts)
      atts.delete_if{|k,_| k.to_s.include?("@") || k == :rid}
    end

    def _sanitized_attributes
      result = []

      model.attributes.each do |field|
        val = send(field)

        if val
          result.push(field, val.to_s)
        end
      end

      return result
    end
  end
  
  #   class Comment < Rorient::Model(DB)
  #   this sets the instance variable @orientdb to the
  #   OrientDB Database 
  def self.Model(source)
    if source.is_a?(Rorient::Client)
      c = Class.new(Rorient::Model)
      c.orientdb = source
      c
    else
      raise(Error, "No OrientDB connection associated with #{self}")
    end
  end
end
