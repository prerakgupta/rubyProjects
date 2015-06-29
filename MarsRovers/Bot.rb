class Bot

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

      def move(way, obj)
          if way=="L"
             @dir = @movement[dir][0]
          elsif way=="R"
             @dir = @movement[dir][1]
          elsif way=="M"
             result = obj.check_shift(@pos_x, @pos_y, @dir)
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
