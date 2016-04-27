require_relative "../support/model_data_test"

ModelDataTest.setup

describe "Rorient::Model" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }
  let(:rorient_test) { Rorient::Model(DB) }

  it "must instantiate a model" do
    rorient_test.superclass.must_be Rorient::Model
  end
end

ModelDataTest.teardown
