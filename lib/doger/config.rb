# frozen_string_literal: true

require 'doger/color'

module Doger
  class Config
    # The default set of colors that will be used by instances of {Doger::Doge}
    # if not explicitly specified by the instance. Can be an array of hex
    # strings, hex symbols, hex integers, arrays of RBG values, or
    # {Doger::Color}, eg:
    #   ['#000000', '#FFFFFF']
    #   %i[000000 FFFFFF]
    #   [0x000000, 0xFFFFFF]
    #   [[0, 0, 0], [255, 255, 255]]
    #   [Doger::Color.new('#000000'), Doger::Color.new('#FFFFFF')]
    #
    # @return [Array<Doger::Color>]
    #
    attr_reader :default_colors

    # The default number of horizontal divisions to split images into when
    # establishing text placement zones.
    #
    # @return [Integer]
    #
    attr_accessor :default_horizontal_divisions

    # The default set of integer pointsizes for text used by instances of {Doger::Doge}
    # if not specified explicitly by the instance. Can be an array or range of
    # integers.
    #
    # @return Array[Integer]
    # @return Range[Integer]
    #
    attr_accessor :default_pointsizes

    # The default number of vertical divisions to split images into when
    # establishing text placement zones.
    #
    # @return [Integer]
    #
    attr_accessor :default_vertical_divisions

    # The image quality setting for the resulting images as a percent,
    # eg, 95 translates to 95%.
    #
    # @return [Integer]
    attr_accessor :image_quality

    class << self
      # @return [Doger::Config]
      attr_writer :instance

      # @return [Doger::Config]
      def instance
        @instance ||= new
      end
    end

    # @param [Hash{Symbol=>Object}] user_config the hash to be used to build the
    #   config
    def initialize(user_config = {})
      self.default_colors = %i[#FFFFFF]
      self.default_horizontal_divisions = 3
      self.default_pointsizes = (17..24)
      self.default_vertical_divisions = 3
      self.image_quality = 95
      merge(user_config)
    end

    # Sets the default colors by converting specified values into instances of
    # {Doger::Color}
    #
    # @return [Array<Doger::Color>]
    #
    def default_colors=(values)
      @default_colors = Array(values).map do |value|
        value.is_a?(Doger::Color) ? value : Doger::Color.new(*value)
      end
    end

    # Merges the given +config_hash+ with itself.
    #
    # @example
    #   config.merge(default_colors: ['#FFFFFF'])
    #
    # @return [self] the merged config
    def merge(config_hash)
      config_hash.each_pair { |option, value| set_option(option, value) }
      self
    end

    private

    def set_option(option, value)
      __send__("#{option}=", value)
    rescue NoMethodError
      raise Doger::Error, "unknown option '#{option}'"
    end
  end
end
