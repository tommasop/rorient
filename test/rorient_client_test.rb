require "helper" 

describe "Rorient::Client" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }

  it "initializes with testing defaults" do
    rorient_client.present?.must_equal true
  end

  it "has a faraday connection" do
    rorient_client.connection.must_be_instance_of(Faraday::Connection)
  end 

  it "lazily initialize resources at their first call" do
    rorient_client.resources.must_be_empty
    rorient_client.document
    rorient_client.resources.keys.must_include :document 
    rorient_client.document.must_be_instance_of(Rorient::DocumentResource)
    rorient_client.document.connection.present?.must_equal true
  end

  it "denies initialization of not defined resources" do
    proc { rorient_client.not_existing_resource }.must_raise NoMethodError
  end

  it "checks table existence in orientdb database" do
    rorient_client.table_exists?("NotExistingTable").must_equal false
    rorient_client.table_exists?("OUser").must_equal true
  end

  it "can create and drop a new class in orientdb database" do
    rorient_client.create_table("NotExistingTable")
    rorient_client.table_exists?("NotExistingTable").must_equal true
    rorient_client.delete_table("NotExistingTable")
    rorient_client.table_exists?("NotExistingTable").must_equal false
  end
end
