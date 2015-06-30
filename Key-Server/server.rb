require 'socket'
require_relative 'Keys.rb'
require_relative 'Time.rb'

def process_url(request)
   request = request.split("/")
   temp = request[1].split
   result = temp[0].split("?")
   if result.size>1
      result[1] = (result[1].split("="))[1]	
   end        
   return result
end

def check_unblock(time_obj, key_obj)
    while true  
	time_obj.unblock(key_obj)
    end
end

def check_remove(time_obj, key_obj)
    while true
    	  time_obj.remove(key_obj)
    end
end	  

server = TCPServer.new('10.100.101.197', 1234)
puts "Server running at 10.100.101.197:1234 ... "

key = Keys.new(20);
time = Time.new();

thread_unblock = Thread.start{check_unblock(time, key)}
thread_remove = Thread.start{check_remove(time, key)}
close_server = false

while !close_server 
     Thread.start(server.accept) do |socket|
	request = socket.gets
	STDERR.puts request
	endpoint = process_url(request)	
	puts ".... #{endpoint}"		
	response = case endpoint[0]
		     when "E1"
		   	key.generate_key(time)
		     when "E2"
		    	key.assign_available_key(time)  
		     when "E3"
		    	key.unblock_key(endpoint[1].to_i, time)
		     when "E4"   
		    	key.delete_key(endpoint[1].to_i, time) 
		     when "E5" 
		    	key.alive(endpoint[1].to_i, time)
		     when "E6"
		    	puts "Available -> #{key.getAvailable}"
			puts "Assigned -> #{key.getAssigned}"
			puts Time.now
			puts "Unblock -> #{time.unblock_time}"
			puts "Remove -> #{time.remove_time}"
			"Debugging at console."  	
		     when "exit"
		    	close_server=true
			"Server closed"			
	             else
		    	"E1 => Generate a Key\nE2 => Get a Key\nE3 => Unblock a Key\nE4 => Delete a Key\nE5 => Alive" 
		   end
        socket.print "HTTP/1.1 200 OK\r\n" +
		      "Content-Type: text/plain\r\n" +
		      "Content-Length: #{response.bytesize}\r\n" +
                      "Connection: close\r\n"
        socket.print "\r\n"		   	
	socket.print response
	socket.close
     end
end

puts "Server closed. No more requests will be accepted"

Thread.kill(thread_unblock)
Thread_kill(thread_remove)
