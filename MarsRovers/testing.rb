require 'test/unit'
require_relative 'Mars.rb'
require_relative 'Bot.rb' 

class TestMarsRovers < Test::Unit::TestCase

      def test_wrong_input_of_moves
      	  assert_output(/Invalid input detected./) { Bot.new(1,1,"N").move("P", Mars.new(0, 0, 3, 3))}
      end

      def test_result_if_bot_goes_out_of_plateau
      	  assert_equal( [4,-1], Mars.new(0,0,4,4).check_shift(4,4,"N") )
	  assert_equal( [-1,2], Mars.new(0,0,4,4).check_shift(0,2,"W") )
      end
      
      def test_correct_movement
      	  assert_equal( [2,3], Mars.new(0,0,5,5).check_shift(2,2,"N") )	  
	  assert_equal( [1,2], Mars.new(0,0,5,5).check_shift(0,2,"E") )
      end
      def test_correct_turn
      	  assert_equal( "S", Bot.new(2,2,"E").move("R", Mars.new(0, 0, 4, 4)))
	  assert_equal( "E", Bot.new(2,2,"S").move("L", Mars.new(0, 0, 4, 4)))
      end	  
end
