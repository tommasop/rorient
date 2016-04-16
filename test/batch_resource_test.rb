require "helper" 

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

describe "BatchResource" do

  it "does something" do
    true.must_equal false
  end

end
