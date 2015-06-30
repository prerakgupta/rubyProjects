require 'date'
require_relative 'Keys.rb'

class Time
	@@remove_time = Hash.new(-1)
	@@unblock_time = Hash.new(-1)

	def unblock_time
	    @@unblock_time
	end

	def remove_time
	    @@remove_time
	end
        
def unblock(key_obj)
    t = @@unblock_time.select{|k,v| k<=Time.now}
    
    if t.size>0
       t.each do |k, v|
       	      keys = @@unblock_time[k]
       	      puts "Keys to unblock #{keys}"
       	      keys.each do |key|
              		key_obj.unblock_key(key, self)	
	  		puts "Unblocked #{key}"	 
       	      end
	      if @@unblock_time[k].size==0
	      	 @@unblock_time.delete(k)
	      end	 
    	end
    end	  
end

def remove(key_obj)
    t = @@remove_time.select{|k,v| k<=Time.now}
    
    if t.size>0
       t.each do |k, v|
       	      keys = @@remove_time[k]
       	      puts "Keys to remove #{keys}"
       	      keys.each do |key|
       		 key_obj.delete_key(key, self)
       		 puts "Removed #{key}"
       	      end
       	      if @@remove_time[k].size==0
       	      	 @@remove_time.delete(k)
       	      end
	end      	  
    end
end

def add_in_remove(time, id)
    if @@remove_time[time]==-1
       @@remove_time[time] = [id]
    else
	     @@remove_time[time] << id
    end
end

def add_in_unblock(time, id)
    if @@unblock_time.has_key?(time)
        @@unblock_time[time] << id
    else
	@@unblock_time[time] = [id]
    end
end
end
