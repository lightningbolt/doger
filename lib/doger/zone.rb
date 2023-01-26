# frozen_string_literal: true

require 'doger/geometry'

module Doger
  class Zone < Doger::Geometry::Rectangle
    attr_accessor :coordinate_choices, :x_choices, :y_choices

    def initialize(top_left, bottom_right, coordinate_choices: nil, x_choices: nil, y_choices: nil)
      super(top_left, bottom_right)
      if coordinate_choices
        @coordinate_choices = coordinate_choices
      else
        @x_choices = x_choices || (top_left.x..bottom_right.x)
        @y_choices = y_choices || (top_left.y..bottom_right.y)
      end
    end

    def random_point
      if coordinate_choices
        Doger::Geometry::Point.new(*coordinate_choices.sample)
      else
        Doger::Geometry::Point.new(
          x_choices.sample,
          y_choices.sample
        )
      end
    end
  end
end
