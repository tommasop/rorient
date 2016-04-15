require 'rubygems'
$:.unshift File.expand_path('../../lib', __FILE__)

begin
    gem 'minitest', '~> 5'
rescue Gem::LoadError
end

require 'minitest/autorun'
require "rack-minitest/test"
require 'rorient'

class Rorient::TestCase < Minitest::Unit::TestCase
  def test_order
    :alpha
  end

  def setup
    @db = Rorient.connect(server: "http://159.122.132.173:2480", user: 'test', password: 'test_PWD$2016', db_name: 'test_rorient') 
  end
end

