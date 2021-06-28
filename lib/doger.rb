# frozen_string_literal: true

require 'doger/config'
require 'doger/version'

# Doger is a library for generating Doge or Doge-like meme pictures.
#
# Prior to using it, you must {configure} it and optionally configure {MiniMagick}.
module Doger
  class Error < StandardError; end

  class << self
    # Gets the Doger configuration class instance.
    #
    # @return [Doger::Config]
    def config
      @config ||= Doger::Config.instance
    end

    # Configures Doger.
    #
    # @example
    #   Doger.configure do |config|
    #     config.default_colors = %w[#000000 #FFFFFF] # black and white
    #     config.default_pointsizes = [17, 18]
    #   end
    #
    # @yield [config]
    # @yieldparam config [Doger::Config]
    # @return [void]
    def configure
      yield config = Doger::Config.instance
      @config = config
    end
  end
end

require 'doger/doge'
