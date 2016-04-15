require_relative "helper"
DB = Rorient.connect(server: "http://159.122.132.173:2480/", user: "rorient_check", password: "ch3ckIT", db_name: "rorient_check") 

class Urbobj < Rorient::Model 
end

setup do
  $users = {}
  $users["foo@bar.com"] = User.new("foo@bar.com", "pass1234")
end

test "fetch" do |user|
  assert_equal user, User.fetch("foo@bar.com")
end

test "authenticate" do |user|
  assert_equal user, User.authenticate("foo@bar.com", "pass1234")
end
