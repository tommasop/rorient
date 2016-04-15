require File.expand_path('../../helper', __FILE__)

class TestBatchResource < Rorient::TestCase
  def test_statements_execution
    sql_statements = { transaction: false,
                       operations: [
                         {
                           type: "script",
                           language: "sql",
                           script: [ 
                                     "CREATE CLASS RorientTest",
                                     "CREATE PROPERTY RorientTest.time DOUBLE",
                                     "CREATE PROPERTY RorientTest.executed DATETIME",
                                     "CREATE PROPERTY RorientTest.name STRING",
                                     "CREATE PROPERTY RorientTest.type STRING",
                                     "CREATE INDEX RorientTest.time_type ON RorientTest (time, type) NOTUNIQUE_HASH_INDEX"
                           ]
                         }
                       ]
                     }
    assert_equal({:result=>[{:@type=>"d", :@version=>0, :value=>0, :@fieldTypes=>"value=l"}]}, @db.batch.execute(sql_statements))
  end
end

