class GreedyGame
   attr_reader :score
   attr_reader :playing
   
   def initialize(num)
        @playing = num
        @score = Array.new(num, 0)
   end

   def calculate_score(dice_values)
        freq = Array.new(6, 0)
        total_score = 0
	  
        dice_values.each do |val|
	   freq[val-1] += 1 
        end
	
	while freq[0]>=3
    	    total_score+=1000
            freq[0]-=3
    	end
        current_num = 1
       
        freq.each do |item|
            while item>=3
            	  total_score+= 100*current_num
            	  freq[current_num-1]-=3
            	  item-=3
            end
            current_num+=1
    	end
    	while freq[0]>0
              total_score+=100
              freq[0]-=1
    	end
        while freq[4]>0
              total_score+=50
              freq[4]-=1
         end
	 result = {:frequency => freq, :totalScore => total_score}
    return result
   end    
   
   def roll(num_of_dices)
        return if num_of_dices<=0
        assigned = Array.new(num_of_dices, 0)
        while num_of_dices>=0
          num_of_dices-=1
          assigned[num_of_dices] = rand(1..6)
        end
	return assigned
   end

   def roll_again(result)
       freq = result[:frequency]
       unused_dices = 0
       freq.each do |val|
          unused_dices+=val if val>0		 
       end
       avail_dices = unused_dices==0? 5 : unused_dices
       if avail_dices>0
       	  puts "Player #{result[:player]} your current turn score is #{result[:totalScore]} and you have #{avail_dices} more dices to throw. Do you wanna throw again?"
	  choice = ""
	  while (choice!="y" && choice!="n")
	  	 puts "Enter y for yes and n for no"
		 choice = gets.chomp
	  end
	end
	choice = choice=="n"? "n" : avail_dices.to_s 		 
	return choice  	 	    
   end

   def update_score(player_num, final_score)
       score[player_num-1] += final_score
       puts "\nPlayer #{player_num} your score in the current round is #{final_score}.\n\n" 
   end

end

puts "\n\n\nWelcome to the game of greed. Please enter the number of players.\n"
num_of_players = 0
while num_of_players<2
   puts "Minimum of 2 players."
   num_of_players = (gets.chomp).to_i
end

puts"\nOk so lets start the game.\n\n\n"

game = GreedyGame.new(num_of_players)
round = 1
final_round = false
check_final = 0
temp = 0  #to temporarily save the score obtained 

while true && !final_round
      num_of_dices = 5
      players = 1
      final_round = check_final==1? true: false
      temp = 0
      puts "Current Scores: #{game.score}"
      puts "Round #{round} starting... \n\n" 
      while players<=game.playing
      	    assigned = game.roll(num_of_dices)
	    result = game.calculate_score(assigned)
	    current_score = temp + result[:totalScore]
	    puts "Player #{players} your dice values #{assigned} and your score so far in this round is #{current_score}."
	    result[:player] = players
	    if (game.score[players-1] < 300 && current_score<300) || (result[:totalScore]==0)
	       puts "Score added in this round is 0. Wait for your next turn.\n*********************\n"
	    else
	       choice = game.roll_again(result)
	       if choice=="n"
	       	  temp += result[:totalScore]
	       	  game.update_score(players, temp)
		else
		  num_of_dices = choice.to_i
		  temp += result[:totalScore]
		  next	
		end  
	    end   	   
      	    players+=1
	    num_of_dices = 5
	    temp = 0
      end     
      game.score.each do |val|
            check_final = 1 if val>=1500
      end	
      round+=1
      puts "\n###########################################\n"    
end

puts "\n\n\nThe final score board is #{game.score}."
winning_score = game.score.max
print "The winner is "
index = 1
game.score.each do |val|
	print "Player #{index} " if val==winning_score
	index+=1
end
puts "Congratulations the winners get a free ruby tutorial, go get it at rubykoans.com \n\n"
