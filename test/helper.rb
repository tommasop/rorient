require 'rubygems'
$:.unshift File.expand_path('../../lib', __FILE__)

begin
    gem 'minitest', '~> 5'
rescue Gem::LoadError
end

require 'minitest/autorun'
require 'rorient'

class Rorient::TestCase < Minitest::Test

  def setup
  end

  def teardown
  end

end

