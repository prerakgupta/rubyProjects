require_relative 'spec_helper'

obj_key = Keys.new(20)
obj_time = Time.new()

describe "test generating a new key" do
	 it "generates a new key" do
	    expect(obj_key.generate_key(obj_time)).to match("New key")
	  end
end

describe "test assigning key" do
	 it "assigns an available key" do
	    expect(obj_key.assign_available_key(obj_time)).to match("New key assigned") 
	    expect(obj_key.assign_available_key(obj_time)).to match("No keys")
	 end
end    

describe "test unblocking a key" do
	 it "unblocks a key" do
	    expect(obj_key.unblock_key(1, obj_time)).to match("Key with id")
	    expect(obj_key.unblock_key(3, obj_time)).to match("Invalid key")
	  end
end

describe "test alive functionality" do
	 it "resets the remove time of a key" do
	    expect(obj_key.alive(4, obj_time)).to match ("Key does not exist")
  end
end

describe "test delete function" do
	 it "deletes a key" do
	    expect(obj_key.delete_key(1, obj_time)).to match ("Key with id")
	    expect(obj_key.delete_key(4, obj_time)).to match ("Invalid")
          end
end
