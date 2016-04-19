require_relative "../helper"

describe "Rorient::Batch" do
  let(:default_hash) { { transaction: false, operations: [ { type: "script", language: "sql", script: [] } ] } }

  it "must initialize with a statements array as instance variable" do
    rorient_batch = Rorient::Batch.new
    rorient_batch.instance_variable_get(:@statements).must_equal []
  end

  it "must have a method to generate the Orientdb default hash" do
    rorient_batch = Rorient::Batch.new
    rorient_batch.generate_hash.must_equal default_hash
  end

  it "must be initialized through an array of statements" do
    statements = ["begin", "select from OUser", "end"]
    rorient_batch = Rorient::Batch.new(statements: statements) 
    rorient_batch.instance_variable_get(:@statements).must_equal statements
  end
  
  it "must be initialized through a string of statements and a separator" do
    statement = "begin;select from OUser;end"
    separator = ";"
    rorient_batch = Rorient::Batch.from_string(statement: statement, with_separator: separator) 
    rorient_batch.instance_variable_get(:@statements).must_equal statement.split(separator)
  end

  it "must generate correct OrientDB hash with statements" do
    statements = ["begin", "select from OUser", "end"]
    rorient_batch = Rorient::Batch.new(statements: statements) 
    default_hash[:operations][0][:script] = statements
    rorient_batch.generate_hash.must_equal default_hash
  end

  it "must enable a transaction if asked to" do
    rorient_batch = Rorient::Batch.new
    rorient_batch.generate_hash(with_transaction: true)[:transaction].must_equal true
  end
end
