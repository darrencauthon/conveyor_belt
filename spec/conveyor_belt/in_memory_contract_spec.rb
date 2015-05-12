require_relative '../spec_helper'

describe ConveyorBelt::InMemoryContract do

  let(:contract) { ConveyorBelt::InMemoryContract.new }

  describe "start mass operation definition" do
    it "should exist" do
      contract.start_mass_operation_definition nil
    end
  end

  describe "ignore single operation" do
    it "should exist" do
      contract.ignore_target nil
    end
  end

  describe "execute target" do
    it "should store the target id" do
      id1, id2 = random_string, random_string
      contract.execute_target id1
      contract.execute_target id2
      contract.target_ids.must_equal [id1, id2]
    end
  end

end
