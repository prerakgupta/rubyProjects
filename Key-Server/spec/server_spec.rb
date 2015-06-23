require 'spec_helper'

describe "#generate_keys" do
    it "generates a new key" do
        expect(generate_key()).to match "New key generated"
    end		
end

describe "#assign_available_key" do
    it "assigns an available key" do
        expect(assign_available_key()).to match "New key assigned"
	expect(assign_available_key()).to match "No keys"
    end
end

describe "#unblock_key" do
     it "unblocks a key" do
     	 expect(unblock_key(1)).to match "Key with id 1 and"
	 expect(unblock_key(1)).to match "This key"
	 expect(unblock_key(7)).to match "Invalid"
     end
end	 	 

describe "#alive" do
     it "resets the death time of the key to Current Time" do
     	 expect(alive(1)).to match "Restarted time for key"
	 expect(alive(5)).to match "Key does not exist"
     end
end	 	
