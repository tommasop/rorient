require_relative "../helper"

describe "Rorient::Batch" do
  DEFAULT_HASH = { transaction: false, operations: [ { type: "script", language: "sql", script: [] } ] }

  it "must initialize with a statements array as instance variable" do
    rorient_batch = Rorient::Batch.new
    rorient_batch.instance_variable_get(:@statements).must_equal []
  end

  it "must have a method to generate the Orientdb default hash" do
    rorient_batch = Rorient::Batch.new
    rorient_batch.generate_hash.must_equal DEFAULT_HASH
  end

  it "must be initialized through an array of statements" do
    statements = ["begin", "select from OUser", "end"]
    rorient_batch = Rorient::Batch.new(statements) 
    rorient_batch.instance_variable_get(:@statements).must_equal statements
  end
end
