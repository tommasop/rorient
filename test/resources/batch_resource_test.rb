require_relative "../helper" 

describe "Rorient::BatchResource" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }
  let(:rorient_batch)  { Rorient::Batch.new }

  it "executes a batch of commands on db" do
    skip("TODO")
  end
  
  it "returns the errors array if the batch is wrong" do
    skip("TODO")
  end
end
