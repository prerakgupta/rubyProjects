require 'socket'
require 'securerandom'
require 'date'

class Keys
      
      attr_accessor :created_time
      attr_accessor :assigned
      attr_accessor :assigned_time
      attr_reader :value
      attr_reader :id 
       
      def initialize(len)
      	  @assigned = false
	  @value = generate_key_value(20)
	  @created_time = Time.now
	  @assigned_time = -1
	  @id = $avail_keys.size + 1
      end

      def generate_key_value(len)
      	  return SecureRandom.hex(len)
      end
end


server = TCPServer.new('10.100.101.197', 1234)    #10.100.101.197
puts "Server running at 10.100.101.197:1234 ... "

$avail_keys = []
$assign_keys = []
$map_avail = Hash.new(-1)
$map_assign = Hash.new(-1)
$remove_time = Hash.new(-1)
$unblock_time = Hash.new(-1)
$response_code = "200 OK"

def generate_key()
    new_key = Keys.new(20)
    $avail_keys << new_key
    val = $avail_keys.size - 1
    $map_avail[new_key.id] = val
    add_remove( (new_key.created_time+90), new_key.id )
    return "New key generated.\nValue = #{new_key.value}\nId = #{new_key.id}"
end

def assign_available_key()
    key1 = $map_avail.keys	
    num = key1.size
    if(num==0)
	$response_code = "404 Not found"
	return "No keys available."
    else
	random = num==1? key1[0] : key1[ rand(1..num)%num ]
    	new_key = $avail_keys[$map_avail[random]]
    	new_key.assigned = true	    
	new_key.assigned_time = Time.now
	
	$assign_keys << new_key
	val = $assign_keys.size - 1
	$map_assign[new_key.id] = val
	$avail_keys.delete(new_key)
	$map_avail.delete(random)
	add_unblock( (new_key.assigned_time+60), new_key.id ) 
	return "New key assigned.\nId = #{new_key.id}\nValue = #{new_key.value}"
    end	    
end

def delete_key(id)
    index1 = $map_avail[id]
    index2 = $map_assign[id]
   
    if index1!=-1
       value = $avail_keys[index1].value
       $remove_time[ $avail_keys[index1].created_time + 90]-= [$avail_keys[index1].id]      
       $avail_keys -= [ $avail_keys[index1] ]
       $map_avail.delete(id)
 
    elsif index2!=-1
       value = $assign_keys[index2].value
       $unblock_time[ $assign_keys[index2].assigned_time + 60]-= [$assign_keys[index2].id]
       $remove_time[ $assign_keys[index2].created_time + 90]-= [$assign_keys[index2].id]
       $assign_keys -= [ $assign_keys[index2] ]
       $map_assign.delete(id)
    else
       value = -1	
    end      

    if value==-1
       $response_code = "404 Not Found"
       return "Invalid Key id. Not Found"
    else
       return "Key with id #{id} and value: #{value} has been successfully deleted!" 
    end   
end

def unblock_key(id)
    index = $map_assign[id]
    if index!=-1
       new_key = $assign_keys[index]
       $unblock_time[ new_key.assigned_time + 60]-= [new_key.id]
       $assign_keys -= [new_key]
       $map_assign.delete(id)
       new_key.assigned = false
       new_key.assigned_time = -1
       $avail_keys << new_key
       val = $avail_keys.size - 1
       $map_avail[new_key.id] = val
       return "Key with id #{id} and value #{new_key.value} has been unblocked!"
    elsif $map_avail[id]!=-1
       return "This key hasn't been assigned yet therefore you can't unclock it."	  	  
    else
       $response_code = "404 Not Found"
       return "Invalid Key id, Key not found."		
    end
end

def alive(id)
    if $map_assign.has_key?(id)
       new_key = $assign_keys[ $map_assign[id] ]
       puts "Initial remove time: #{new_key.created_time+90}"
       if ( ($remove_time[new_key.created_time + 90])!=-1 )
	  $remove_time[ new_key.created_time + 90] -= [id]
       end	  	  
       new_key.created_time = Time.now
       puts "Current time: #{Time.now}"
       add_remove( (new_key.created_time+90), new_key.id )
       puts "Final remove time: #{new_key.created_time + 90}"
       return "Restarted time for key with id #{id}"
     else
	return "Key hasn't been assigned."  
     end	
end

def unblock()
    #puts "Unblock"
    keys = $unblock_time[Time.now]
    if keys != -1
       puts "#{keys}"
       keys.each do |key|
          unblock_key(key)	
	  puts "Unblocked #{key}"	 
       end
    end  
end

def remove()
    #puts "Remove"
    keys = $remove_time[Time.now]
    if keys != -1
       puts "#{keys}"
       keys.each do |key|	 
       	delete_key(key)
	puts "Removed #{key}"
       end
    end   	    
end

def process_url(request)
   request = request.split("/")
   temp = request[1].split
   result = temp[0].split("?")
   if result.size>1
      result[1] = (result[1].split("="))[1]	
   end        
   return result
end

def add_remove(time, id)
    if $remove_time.has_key?(time)
       $remove_time[time] << id
    else
	$remove_time[time] = [id]
    end
    puts "#{$remove_time}"   
end

def add_unblock(time, id)
    if $unblock_time.has_key?(time)
        $unblock_time[time] << id
    else
	$unblock_time[time] = [id]
    end
    puts "#{$unblock_time}"
end

def time_check()
    while true
	unblock()  
	remove()
    end
end

t1 = Thread.start{time_check()}

loop do
     
     Thread.start(server.accept) do |socket|
     	request = socket.gets
	STDERR.puts request
	endpoint = process_url(request)
	puts  "#{endpoint}"		
	response = if endpoint[0]=="E1"
			generate_key()
		    elsif endpoint[0]=="E2"
		    	assign_available_key()  
		    elsif endpoint[0]=="E3"
		    	unblock_key(endpoint[1].to_i)		
		    elsif endpoint[0]=="E4"   
		    	delete_key(endpoint[1].to_i) 
		    elsif endpoint[0]=="E5" 
		    	alive(endpoint[1].to_i)
		    elsif endpoint[0]=="E6"
		    	puts "Available -> #{$map_avail}"
			puts "Assigned -> #{$map_assign}"
			puts Time.now
			puts "Unblock -> #{$unblock_time}"
			puts "Remove -> #{$remove_time}"
			"Debugging at console."  	
	            else
		    	"E1 => Generate a Key\nE2 => Get a Key\nE3 => Unblock a Key\nE4 => Delete a Key\nE5 => Alive" 
		    end				   	  			
	socket.print "HTTP/1.1 #{$response_code}\r\n" +
		     "Content-Type: text/plain\r\n" +
		     "Content-Length: #{response.bytesize}\r\n" +
		     "Connection: close\r\n"
        socket.print "\r\n"
	socket.print response
	socket.close
	end

end
