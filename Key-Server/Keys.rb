require 'date'
require 'securerandom'
require_relative 'Time.rb'

class Keys
      
      	@@avail_keys = []
      	@@assign_keys = []
     	@@map_avail = Hash.new(-1)
      	@@map_assign = Hash.new(-1)
	@@count = 0
	@@delete_timeout = 100
	@@unblock_timeout = 60
      	attr_accessor :id
	attr_accessor :value
	attr_accessor :assigned
	attr_accessor :created_time
	attr_accessor :assigned_time
       
      	def initialize(len)
      	  @assigned = false
	  @value = generate_key_value(len)
	  @created_time = Time.now
	  @assigned_time = -1
 	  @id = @@count
	  @@count = @@count + 1
      	end
		
	def getAvailable
	    @@map_avail
	end

	def getAssigned
	    @@map_assign
	end    

      	def generate_key_value(len)
      	  return SecureRandom.hex(len)
      	end

	def generate_key(time)
	  puts "Generating key"
    	  new_key = Keys.new(20)
    	  @@avail_keys << new_key
    	  val = @@avail_keys.size - 1
    	  @@map_avail[new_key.id] = val
    	  time.add_in_remove( (new_key.created_time + 100), new_key.id )
    	  return "New key generated.\nValue = #{new_key.value}\nId = #{new_key.id}"
	end

	def assign_available_key(time)
    	  key1 = @@map_avail.keys	
    	  num = key1.size
    	  if(num==0)
		return "No keys available."
    	  else
		random = num==1? key1[0] : key1[ rand(1..num)%num ]
    		new_key = @@avail_keys[@@map_avail[random]]
    		new_key.assigned = true	    
		new_key.assigned_time = Time.now
	
		@@assign_keys << new_key
		val = @@assign_keys.size - 1
		@@map_assign[new_key.id] = val
		@@avail_keys.delete(new_key)
		@@map_avail.delete(random)
		time.add_in_unblock( (new_key.assigned_time + @@unblock_timeout), new_key.id ) 
		return "New key assigned.\nId = #{new_key.id}\nValue = #{new_key.value}"
    	  end	    
	end

	def delete_key(id, time)
    	  index1 = @@map_avail[id]
    	  index2 = @@map_assign[id]
   
    	  if index1!=-1
       		value = @@avail_keys[index1].value
       		time.remove_time[@@avail_keys[index1].created_time + @@delete_timeout]-= [@@avail_keys[index1].id]      
       		@@avail_keys -= [@@avail_keys[index1]]
       		@@map_avail.delete(id)
 
	  elsif index2!=-1
       		value = @@assign_keys[index2].value
       		time.unblock_time[ @@assign_keys[index2].assigned_time + @@unblock_timeout]-= [@@assign_keys[index2].id]
       		time.remove_time[ @@assign_keys[index2].created_time + @@delete_timeout]-= [@@assign_keys[index2].id]
       		@@assign_keys -= [ @@assign_keys[index2] ]
       		@@map_assign.delete(id)
    	  else
       		value = -1	
    	  end      

    	  if value==-1
       		return "Invalid Key id. Not Found"
    	  else
       		return "Key with id #{id} and value: #{value} has been successfully deleted!" 
    	  end   
	end

       def unblock_key(id, time)
    	  index = @@map_assign[id]
	  puts "Unblocking id #{id} at index #{index}"
    	  if index!=-1
       		new_key = @@assign_keys[index]
       		time.unblock_time[ new_key.assigned_time + @@unblock_timeout]-= [new_key.id]
		@@assign_keys -= [new_key]
       		@@map_assign.delete(id)
       		new_key.assigned = false
       		new_key.assigned_time = -1
       		@@avail_keys << new_key
       		val = @@avail_keys.size - 1
       		@@map_avail[new_key.id] = val
       		return "Key with id #{id} and value #{new_key.value} has been unblocked!"
	  elsif @@map_avail[id]!=-1
	  	return "This key has not been assigned yet."	
	  else
       		return "Invalid key id. Key not found."
    	  end
	end


	def alive(id, time)
    	  if @@map_assign.has_key?(id)
       		new_key = @@assign_keys[ @@map_assign[id] ]
    	  elsif @@map_avail.has_key?(id)
      		new_key = @@avail_keys[@@map_avail[id]]
    	  end 
    	  if new_key 	     
    		if ( (time.remove_time[new_key.created_time + @@delete_timeout])!=-1 )
	      		time.remove_time[ new_key.created_time + 40] -= [id]
    		end	  
        	new_key.created_time = Time.now
    		time.add_in_remove( (new_key.created_time + @@delete_timeout), new_key.id)
		return "Restarted time for key with #{id}"
    	  else
		return "Key does not exist."
    	  end	  	
       end
end
