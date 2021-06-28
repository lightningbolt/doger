# frozen_string_literal: true

require 'doger'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/pride'
require 'minitest/reporters'

Minitest::TestCase.test_order = :random
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
