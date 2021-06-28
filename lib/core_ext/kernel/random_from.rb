# frozen_string_literal: true

module Kernel
  # Returns a random object from from an {Array} or {Range}.
  #
  # @param values [Array, Range] Possible values to choose from.
  #
  # @return [Object]
  def random_from(values)
    case values
    when Array
      values.sample
    when Range
      rand(values)
    end
  end
end
