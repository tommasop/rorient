require "rorient"
require "minitest/autorun"
require "purdytest"

Dir['./test/support/**/*.rb'].each do |file|
    require file
end

class Testing
  SERVER = ENV['SERVER'] || "http://159.122.132.173:2480"
  USER  = ENV['USER']  || "test"
  PASSWORD  = ENV['PASSWORD']  || "rorientT3st2016"
  DATABASE   = ENV['DATABASE']  || "test_rorient"
end

