require_relative "../helper" 

describe "Rorient::QueryResource" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }

  it "executes a query on db" do
    result = rorient_client.query.execute(query_text: URI.encode_www_form_component("SELECT FROM OUser")) 
    result.must_be_instance_of Hash
    result.keys.must_include :result
    result[:result].count.must_equal 4
  end

  it "doesn't execute the query if it's not properly encoded" do
    proc { rorient_client.query.execute(query_text: "SELECT FROM OUser") }.must_raise URI::InvalidURIError 
  end
  
  it "returns the errors array if the query is wrong" do
    result = rorient_client.query.execute(query_text: URI.encode_www_form_component("SELECT FROM NotExistingClass")) 
    result.must_be_instance_of Hash
    result.keys.must_include :errors
    result[:errors].must_be_instance_of Array
    result[:errors][0][:code].must_equal 500
  end
end
