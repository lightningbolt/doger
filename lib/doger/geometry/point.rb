# frozen_string_literal: true

module Doger
  module Geometry
    class Point
      attr_reader :x, :y

      def initialize(x, y)
        @x = x
        @y = y
      end

      def distance_to(point)
        Point.distance_between(self, point)
      end

      def to_a
        [x, y]
      end

      def to_s
        "(#{x}, #{y})"
      end

      class << self
        def distance_between(point1, point2)
          Math.sqrt(
            point1.to_a.zip(point2.to_a).reduce(0) { |sum, p| sum + (p[0] - p[1])**2 }
          )
        end
      end
    end
  end
end
