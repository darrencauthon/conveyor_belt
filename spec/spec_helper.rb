require_relative '../lib/conveyor_belt'
require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'

def random_string
  SecureRandom.uuid
end

class TestContract < ConveyorBelt::Contract
end
