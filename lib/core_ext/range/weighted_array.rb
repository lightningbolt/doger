# frozen_string_literal: true

class Range
  def to_weighted_array
    midpoint = ((max - min) / 2).ceil
    array = []
    each_with_index do |int, i|
      num_elements = i > midpoint ? size - i : i + 1
      array += Array.new(num_elements, int)
    end
    array
  end
end
