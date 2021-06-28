# frozen_string_literal: true

require 'doger/geometry'

module Doger
  class TextRegion < Doger::Geometry::Rectangle
    attr_reader :color

    def initialize(top_left, bottom_right, color)
      super(top_left, bottom_right)
      @color = color
    end

    # Returns true if the rectangle overlaps other using image
    # coordinates (ie, +x goes right, +y goes down).
    #
    # @return [Boolean]
    def overlaps?(other)
      # if one rectangle is on left side of other
      return false if (top_left.x > other.bottom_right.x) || (other.top_left.x > bottom_right.x)
      # if one rectangle is above other
      return false if (top_left.y > other.bottom_right.y) || (other.top_left.y > bottom_right.y)

      true
    end
  end
end
