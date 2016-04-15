require File.expand_path('../../helper', __FILE__)

class TestBatchResource < Rorient::TestCase
  UP_STATEMENTS = { transaction: false,
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

    DOWN_STATEMENTS = { transaction: false,
                       operations: [
                         {
                           type: "script",
                           language: "sql",
                           script: [ 
                                     "DROP CLASS RorientTest"
                           ]
                         }
                       ]
                     }

  def test_statements_execution
    assert_equal({:result=>[{:@type=>"d", :@version=>0, :value=>0, :@fieldTypes=>"value=l"}]}, @db.batch.execute(UP_STATEMENTS))
  end

  def test_statement_failure_on_repetition
    assert_includes(@db.batch.execute(UP_STATEMENTS), ":code=>500")
  end
end

