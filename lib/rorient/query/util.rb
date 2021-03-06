module Rorient::Query::Util
  def bark(message)
    raise Rorient::Query::Error.new(message)
  end

  def array_wrap(val)
    val.is_a?(Array) ? val : [val]
  end

  # perl-like argument parser of my ($a, $b) = @_;
  def parse_args(*args)
    if args.size > 1
      # method('a', 'b') #=> ['a', 'b']
      return args #.map{ |arg| parse_args(arg) }
    else
      args = args.first
      case args
      when Hash
        # method('a' => 'b') #=> ['a', 'b']
        # method('a' => ['b', 'c']) #=> ['a', ['b', 'c']]
        # method('a' => {'b' => 'c'}) #=> ['a', {'b' => 'c'}]
        args.each.first
      when Array
        # method(['a', 'b']) #=> ['a', 'b']
        return args
      else
        # method('a') #=> ['a', nil]
        return [args, nil]
      end
    end
  end

  def quote_identifier(label, quote_char, name_sep)
    return label if label == '*'
    return label unless name_sep
    label.to_s.split(/#{Regexp.escape(name_sep)}/).map {|e| e == '*' ? e : "#{quote_char}#{e}#{quote_char}" }.join(name_sep)
  end
  # module_function :quote_identifier
  # public :quote_identifier

  def bind_param(sql, bind)
    raise Rorient::Maker::Error.new('bind arity mismatch') if sql.count('?') != bind.size
    i = -1; sql.gsub('?') { Rorient::Maker::Quoting.quote(bind[i+=1]) }
  end
  # module_function :bind_param
  # public :bind_param
end
