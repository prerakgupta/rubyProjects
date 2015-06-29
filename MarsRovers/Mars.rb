class Mars

      def Mars.start_x
          @@start_x
      end
      def Mars.start_y
          @@start_y
      end
      def Mars.last_x
          @@last_x
      end
      def Mars.last_y
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

          if ( x>=@@start_x.to_i && x<=(@@last_x.to_i) )
             result[0] = x
          end
          if ( y>=@@start_y.to_i && y<=(@@last_y.to_i) )
             result[1] = y
           end
           return result
      end
end
