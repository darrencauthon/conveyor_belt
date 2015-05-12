require_relative '../spec_helper'

describe ConveyorBelt::InMemoryContract do

  let(:contract) { ConveyorBelt::InMemoryContract.new }

  describe "start mass operation definition" do

    let(:mass_operation) { Object.new }

    it "should store the mass operation" do
      contract.start_mass_operation_definition mass_operation
      contract.mass_operation.must_be_same_as mass_operation
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

  describe "stop the mass operation definition" do

    let(:mass_operation) do
      Struct.new(:operations).new operations
    end

    describe "and there are two targets to execute" do

      let(:target_ids) { [Object.new, Object.new] }

      let(:operations) { [Struct.new(:target_id).new(Object.new),
                          Struct.new(:target_id).new(target_ids[1]),
                          Struct.new(:target_id).new(target_ids[0]),
                          Struct.new(:target_id).new(Object.new)] }

      before do
        contract.stubs(:target_ids).returns target_ids
      end

      it "should find the matching operations and execute them" do
        operations[1].expects(:execute)
        operations[2].expects(:execute)
        contract.stop_mass_operation_definition mass_operation
      end

    end

  end

end
