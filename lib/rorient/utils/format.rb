module Rorient
  module Format
    WrongArgsFormat = Class.new(StandardError) 
    MissingArgsFormat = Class.new(StandardError) 

    def parse_from(args)
      return WrongArgsFormat unless args.is_a?(String) || args.is_a?(Array) 
      case
      when is_a_class_name(args) || is_a_rid(args)
        [args]
      when is_an_array_of_rids(args) 
        args
      else
        raise WrongArgsFormat 
      end
    end  

    def parse_traverse(args)
      return WrongArgsFormat unless args.is_a?(Hash)
      return MissingArgsFormat unless ([:fields, :from] - args.keys).empty?
      args.delete_if{|k,_| ![:fields, :from, :while, :strategy].include?(k) }
      args.map{ |arg_k, arg_v| args[arg_k] = send("parse_#{arg_k}", arg_v) if respond_to?("parse_#{arg_k}") }
      args
    end

    def parse_fields(args)
      return WrongArgsFormat unless args.is_a?(String) || (args.is_a?(Array) && args.map{|arg| arg.is_a?(String) }.all?)
      args.is_a?(String) ? [args] : args 
    end

    def parse_strategy(args)
      return WrongArgsFormat unless args.is_a?(String) && !["DEPTH_FIRST", "BREADTH_FIRST"].include?(args)
      args
    end

    def is_a_class_name(args)
      args.is_a?(String) && ! Rorient::Rid.new(rid_obj: args).rid? 
    end

    def is_a_rid(args)
      Rorient::Rid.new(rid_obj: args).rid? 
    end

    def is_an_array_of_rids(args)
      args.map{|arg| Rorient::Rid.new(rid_obj: arg).rid?}.all?
    end

    def sanitize_string(arg)
      # TODO
    end
  end
end

