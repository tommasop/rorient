require_relative "../helper" 

describe "Rorient::DocumentResource" do
  let(:rorient_client) { Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE }) }

  it "finds a document through its rid" do
    result = rorient_client.document.find(rid: "5:3") 
    result.must_be_instance_of Hash
    result.keys.must_include :@class
    result.keys.must_include :@rid
    result[:@rid].must_equal "#5:3"
    result[:name].must_equal "test"
  end

  it "returns the errors array if the rid is wrong" do
    result = rorient_client.document.find(rid: "5:") 
    result.must_be_instance_of Hash
    result.keys.must_include :errors
    result[:errors].must_be_instance_of Array
    result[:errors][0][:code].must_equal 500
  end
  
  it "checks if a document exists through its rid" do
    result = rorient_client.document.exists(rid: "5:3") 
    result.must_equal true
  end

  it "returns false if the document doesn't exist" do
    result = rorient_client.document.exists(rid: "200:3") 
    result.must_equal false
  end

  it "creates a new document" do
    new_user = { "@class": "OUser", name: "tommaso", password: "tommaso", status: "ACTIVE" }
    result = rorient_client.document.create(new_user)
    result.must_be_instance_of Hash
    result[:@class].must_equal "OUser"
    result[:name].must_equal "tommaso"
    result[:status].must_equal "ACTIVE"
    rorient_client.document.delete(rid: Rorient::Rid.new(rid_obj: result).rid)
  end
  
  it "doesn't create a duplicate document" do
    new_user = { "@class": "OUser", name: "test", password: "tommaso", status: "ACTIVE" }
    result = rorient_client.document.create(new_user)
    result.must_be_instance_of Hash
    result.keys.must_include :errors
    result[:errors].must_be_instance_of Array
    result[:errors][0][:code].must_equal 500
  end
  
  it "doesn't create a wrong document" do
    new_user = { "@class": "OUser", first_name: "tommaso", pwd: "tommaso", status: "ACTIVE" }
    result = rorient_client.document.create(new_user)
    result.must_be_instance_of Hash
    result.keys.must_include :errors
    result[:errors].must_be_instance_of Array
    result[:errors][0][:code].must_equal 500
  end

  it "updates a document through its rid" do
    result = rorient_client.document.find(rid: "5:0")
    old_version = result[:@version]
    updated_user_data = {rid: "5:0", "@version": result[:@version], name: "administrator", status: "INACTIVE" }
    result = rorient_client.document.update(updated_user_data)
    result.must_be_instance_of Hash
    result[:name].must_equal "administrator"
    result[:status].must_equal "INACTIVE"
    result[:@version].must_equal (old_version + 1)
    result[:name] = "admin"
    result[:status] = "ACTIVE"
    rorient_client.document.update(updated_user_data)
  end
  
  it "doesn't update a document with wrong rid" do
    updated_user_data = {rid: "5:100", "@version": 0, name: "administrator", status: "INACTIVE" }
    result = rorient_client.document.update(updated_user_data)
    result.must_equal false
  end
  
  it "deletes a document through its rid" do
    new_user = { "@class": "OUser", name: "tommaso", password: "tommaso", status: "ACTIVE" }
    result = rorient_client.document.create(new_user)
    rorient_client.document.exists(rid: Rorient::Rid.new(rid_obj: result).rid).must_equal true
    rorient_client.document.delete(rid: Rorient::Rid.new(rid_obj: result).rid).must_equal true
    rorient_client.document.exists(rid: Rorient::Rid.new(rid_obj: result).rid).must_equal false
  end
  
  it "doesn't delete a not existing document" do
    result = rorient_client.document.delete(rid: "5:100")
    result.must_be_instance_of Hash
    result.keys.must_include :errors
    result[:errors].must_be_instance_of Array
    result[:errors][0][:code].must_equal 404
  end
end
