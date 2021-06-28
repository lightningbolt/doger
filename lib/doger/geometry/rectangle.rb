# frozen_string_literal: true

module Doger
  module Geometry
    class Rectangle
      attr_reader :top_left, :bottom_right

      def initialize(top_left, bottom_right)
        @top_left = top_left
        @bottom_right = bottom_right
      end

      def center
        Point.new(
          ((top_left.x + bottom_right.x) / 2),
          ((top_left.y + bottom_right.y) / 2)
        )
      end

      def to_s
        "[#{top_left} #{bottom_right}]"
      end
    end
  end
end
