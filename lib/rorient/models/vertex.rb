module Rorient
  class Vertex
    include Rorient::VertexGraph
    
    # This is the instance variable containing the client
    # to OrientDB HTTP API
    @orientdb = nil
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
      orientdb.document.exists(rid: Rorient::Rid.new(rid_obj: rid).rid)
    end
    
    def self.first
      self.new(orientdb.query.execute(query_text: URI.encode("SELECT FROM #{self.name} order by @rid/1"))[:result].first)
    end
    
    def self.last
      self.new(orientdb.query.execute(query_text: URI.encode("SELECT FROM #{self.name} order by @rid desc/1"))[:result].first)
    end

    # Syntactic sugar for Edge.new(atts).save
    def self.create(atts = {})
      new(atts).save
    end
    
    def initialize(atts={})
      @attributes = {}
      @_memo = {}
      @rid =  begin
                Rid.new(rid_obj: atts).rid 
              rescue Rid::NoRidFound
                nil
              end
      @version = atts[:@version] || 0
      update_attributes(_remove_metadata(atts))
    end 

    # Access the RID used to store this model. 
    #
    # Example:
    #
    #   class User < Rorient::Model(DBCLIENT); end
    #
    #   u = User.create
    #   u.rid
    #   # => 1
    #
    def rid
			Rid.new(rid_obj: @rid).rid
    end

    # Check for equality by doing the following assertions:
    #
    # 1. That the passed model is of the same type.
    # 2. That they represent the same OrientDB key.
    #
    def ==(other)
      other.kind_of?(model) && other.rid == rid
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

    def rid=(value)
      Rid.new(rid_obj: value).rid
    end

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
  
  #   class Comment < Rorient::Vertex(DBCLIENT)
  #   this sets the instance variable @orientdb to the
  #   OrientDB Database 
  def self.Vertex(source)
    if source.is_a?(Rorient::Client)
      c = Class.new(Rorient::Vertex)
      c.orientdb = source
      c
    else
      raise(Error, "No OrientDB connection associated with #{self}")
    end
  end
end
