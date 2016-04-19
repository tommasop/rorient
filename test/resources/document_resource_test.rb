require_relative "../helper" 

describe "Rorient::DocumentResource" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }

  it "finds a document through its rid" do
    result = rorient_client.document.find(rid: "5:3") 
    result.must_be_instance_of Hash
    result.keys.must_include :@class
    result.keys.must_include :@rid
    result[:@rid].must_equal "#5:3"
    result[:name].must_equal "test"
  end

  it "returns the errors array if the rid is wrong" do
    result = rorient_client.document.find(rid: "5:") 
    result.must_be_instance_of Hash
    result.keys.must_include :errors
    result[:errors].must_be_instance_of Array
    result[:errors][0][:code].must_equal 500
  end
end
