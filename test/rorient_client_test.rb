require "helper" 

describe "Rorient::Client" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USER, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }

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
  end
end
