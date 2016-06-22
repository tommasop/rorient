require_relative "../support/model_data_test"

ModelDataTest.setup

describe "Rorient::Model" do
  # let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }
  # let(:rorient_test) { Object.const_set("RorientTest", Rorient::Model(Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }))) }

  it "must instantiate a model" do
    rorient_test.superclass.must_equal Rorient::Model
  end

  it "must set the orientdb attribute and its corresponding instance variable" do
    rorient_test.orientdb.must_be_instance_of Rorient::Client
    rorient_test.instance_variable_get(:@orientdb).must_equal rorient_test.orientdb
  end

  it "must raise error if instantiated without a database" do
    no_db_test = Rorient::Model
    proc { no_db_test.orientdb }.must_raise Rorient::Error
  end 

  it "must check RorientTest exists in database" do
    rorient_test.orientdb.query.execute(query_text: URI.encode("SELECT FROM V WHERE @class = '#{rorient_test.name}'")).present?.must_equal true
  end

  it "checks for object existence by its rid" do
    puts rorient_test.name
    puts rorient_test.orientdb 
    rid = rorient_test.first.rid
    rorient_test.exists?(rid).must_equal true
    rorient_test.exists?("5:100").must_equal false
  end
end

ModelDataTest.teardown
