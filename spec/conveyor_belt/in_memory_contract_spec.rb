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
    it "should track the ids to ignore" do
      target_id = Object.new
      contract.mark_for_ignoring target_id
      contract.target_ids_to_ignore.count.must_equal 1
      contract.target_ids_to_ignore[0].must_equal target_id
    end
  end

  describe "execute" do

    let(:target_id) { Object.new }

    it "should look up the target, then call perform with it" do
      target = Object.new
      contract.stubs(:find).with(target_id).returns target
      contract.expects(:perform).with target
      contract.execute target_id
    end

  end

  describe "execute target" do
    it "should store the target id" do
      id1, id2 = random_string, random_string
      contract.mark_for_execution id1
      contract.mark_for_execution id2
      contract.target_ids_to_execute.must_equal [id1, id2]
    end
  end

  describe "stop the mass operation definition" do

    let(:mass_operation) do
      Struct.new(:operations).new operations
    end

    describe "and there are two targets to execute" do

      let(:target_ids_to_execute) { [Object.new, Object.new] }

      let(:operations) { [Struct.new(:target_id).new(Object.new),
                          Struct.new(:target_id).new(target_ids_to_execute[1]),
                          Struct.new(:target_id).new(target_ids_to_execute[0]),
                          Struct.new(:target_id).new(Object.new)] }

      before do
        contract.stubs(:target_ids_to_execute).returns target_ids_to_execute
      end

      it "should find the matching operations and execute them" do
        operations[1].expects(:execute)
        operations[2].expects(:execute)
        contract.stop_mass_operation_definition mass_operation
      end

    end

  end

end
