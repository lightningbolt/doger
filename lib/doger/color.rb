# frozen_string_literal: true

module Doger
  class Color
    attr_reader :red, :green, :blue

    def initialize(*args)
      case args.size
      when 3
        @red, @green, @blue = args.map(&:to_i)
      when 1
        hex = case (arg = args.first)
              when Integer
                format('#%.6x', arg)
              when Symbol
                arg.to_s
              when String
                arg
              else
                raise(ArgumentError, 'expecting String, Symbol, or Integer hex value')
              end
        hex = hex.sub(/^#/, '')
        @red, @green, @blue = hex[0, 6].scan(/.{2}/).map { |component| component.to_i(16) }
      else
        raise(ArgumentError, 'wrong number of arguments: 1 hex value or 3 rbg values')
      end
    end

    def to_s
      "rgb(#{@red},#{@green},#{@blue})"
    end
  end
end
