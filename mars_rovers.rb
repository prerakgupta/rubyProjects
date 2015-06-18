
class MarsRovers

      def MarsRovers.start_x
          @@start_x
      end
      def MarsRovers.start_y
          @@start_y
      end	  	  	  
      def MarsRovers.last_x
      	  @@last_x
      end
      def MarsRovers.last_y	  
          @@last_y
      end	  	  
          @@position

      def initialize(x1, y1, x2, y2)
      	  @@start_x = x1
	  @@start_y = y1
	  @@last_x = x2
	  @@last_y = y2
	  @@position = { "N" => [0,1], "E" => [1,0], "W" => [-1,0], "S" => [0,-1]}
      end

      def check_shift(x, y, dir)
      	
      	  result = Array.new(2,-1)
	  
	  x = x + @@position[dir][0]
	  y = y + @@position[dir][1]

	  if (x>=@@start_x.to_i && x<=(@@last_x.to_i))
	     result[0] = x
	  end
	  if (y>=@@start_y.to_i && y<=(@@last_y.to_i))
	     result[1] = y
	   end	
	   return result     
      end
end

class Bot < MarsRovers
      
      attr_reader :pos_x
      attr_reader :pos_y
      attr_reader :dir    #direction
      attr_reader :movement

      def initialize(x, y, dir)
      	  @pos_x = x
	  @pos_y = y
	  @dir = dir
	  @movement = { "N" => ["W", "E"], "E" => ["N", "S"], "W" => ["S", "N"], "S" => ["E", "W"]}

      end

      def move(way)
       	  if way=="L"
	     @dir = @movement[dir][0]
	  elsif way=="R"
	     @dir = @movement[dir][1]
	  elsif way=="M"
	     result = check_shift(@pos_x, @pos_y, @dir)
	     if (result[0]==-1 || result[1]==-1)
	     	puts "Careful with your moves, the bot was about to fall off."
	     else
		@pos_x = result[0]
		@pos_y = result[1]
	     end
	  else 
	       puts "Invalid input detected." 
	  end	 			    	   
      end
end

rightmost = gets.chomp
rightmost = rightmost.split(/\s+/)
if(rightmost[0].to_i<=0 || rightmost[1].to_i<=0)
	puts "\nMars is no longer a plateau. Quitting Nasa mission.\n\n"					
else

	squad = MarsRovers.new(0, 0, rightmost[0].to_i, rightmost[1].to_i)
	input = gets.chomp
	
	while(input!=nil)
		cord = input.split(/\s+/)
		if(cord[0].to_i < MarsRovers.start_x.to_i || cord[0].to_i > MarsRovers.last_x || cord[1].to_i < MarsRovers.start_y || cord[1].to_i > MarsRovers.last_y)
			puts "Invalid input. The bot is in outer space!"
			input = gets.chomp
			next
		else		
			new_bot = Bot.new(cord[0].to_i, cord[1].to_i, cord[2])
			sequence = gets.chomp
			index = 0
			while(index<sequence.length)
				letter = sequence[index].upcase
				new_bot.move(letter)
				index+=1
			end
			puts "\nFinal position: #{new_bot.pos_x} #{new_bot.pos_y} #{new_bot.dir}\n"
			puts "\nEnter new position and moves or q to exit"
			input = gets.chomp
			break if input=="q"
		end	
	end
end
