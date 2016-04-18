require "helper" 

describe "Rorient::QueryResource" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }

  it "executes a query on db" do
    result = rorient_client.query.execute(query_text: URI.encode("SELECT FROM OUser")) 
    result.keys.must_include :result
    result[:result].count.must_equal 4
  end

end
