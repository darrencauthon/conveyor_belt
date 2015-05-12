require_relative '../spec_helper'

describe ConveyorBelt::InMemoryContract do

  let(:contract) { ConveyorBelt::InMemoryContract.new }

  describe "start mass operation definition" do

    it "should exist" do
      contract.start_mass_operation_definition nil
    end

  end

end
