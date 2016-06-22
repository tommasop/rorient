require_relative "../helper"

DB = Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE })

class ModelDataTest
  # Create document table and data
  def self.setup
    model_test_setup = ["CREATE CLASS RorientTest EXTENDS V",
                        "CREATE PROPERTY RorientTest.name STRING",
                        "CREATE PROPERTY RorientTest.active BOOLEAN",
                        "INSERT INTO RorientTest(name, active) VALUES ('Marco', true), ('Riccardo', true), ('Tommaso', false)"
    ]
    db_setup = Rorient::Batch.new(statements: model_test_setup).generate_hash 
    puts DB.batch.execute(db_setup)
  end

  def self.teardown
    # Delete document table on DB
    DB.oclass.delete(class_name: "RorientTest")
  end
end 

