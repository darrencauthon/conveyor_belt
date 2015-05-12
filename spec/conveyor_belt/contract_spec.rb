require_relative '../spec_helper'

describe ConveyorBelt::Contract do

  let(:contract) { ConveyorBelt::Contract.new }

  describe "start mass operation definition" do

    let(:mass_operation) { Object.new }

    it "should store the mass operation" do
      contract.start_mass_operation_definition mass_operation
      contract.mass_operation.must_be_same_as mass_operation
    end

  end

  describe "execute" do

    let(:target_id) { Object.new }

    let(:target) { Object.new }

    let(:mass_operation) { Object.new }

    before do
      contract.stubs(:mass_operation).returns mass_operation
      contract.stubs(:find).with(target_id).returns target
      contract.stubs :perform
      mass_operation.stubs :succeeded!
    end

    it "should look up the target, then call perform with it" do
      contract.expects(:perform).with target
      contract.execute target_id
    end

    it "should pass the id to the mass operation as a success" do
      mass_operation.expects(:succeeded!).with target_id
      contract.execute target_id
    end

    it "should pass the id to the mass operation, but after the step is performed" do
      mass_operation.stubs(:succeeded!).with do |target_id|
        contract.stubs(:perform).raises 'called too early'
      end
      contract.execute target_id
    end

  end

  describe "stop the mass operation definition" do

    let(:mass_operation) do
      Struct.new(:operations, :examined_list).new operations, examined_list
    end

    describe "and there are two targets to execute, and two to ignore" do

      let(:target_ids_to_execute) { [Object.new, Object.new] }
      let(:target_ids_to_ignore)  { [Object.new, Object.new] }

      let(:operations) { [Struct.new(:target_id).new(target_ids_to_ignore[0]),
                          Struct.new(:target_id).new(target_ids_to_execute[1]),
                          Struct.new(:target_id).new(target_ids_to_execute[0]),
                          Struct.new(:target_id).new(target_ids_to_ignore[1])] }

      let(:examined_list) do
        [target_ids_to_execute.map { |x| { 'target_id' => x, 'task' => :mark_for_execution } },
         target_ids_to_ignore.map  { |x| { 'target_id' => x, 'task' => :mark_for_ignoring } }].flatten
      end

      before do
        operations.each do |operation|
          operation.stubs :execute
          operation.stubs :ignore
        end
      end

      it "should find the matching operations and execute them" do
        operations[1].expects(:execute)
        operations[2].expects(:execute)

        operations[0].stubs(:execute).raises 'error'
        operations[3].stubs(:execute).raises 'error'

        contract.stop_mass_operation_definition mass_operation
      end

      it "should find the operations to ignore, and ignore them" do
        operations[0].expects(:ignore)
        operations[3].expects(:ignore)

        operations[1].stubs(:ignore).raises 'error'
        operations[2].stubs(:ignore).raises 'error'

        contract.stop_mass_operation_definition mass_operation
      end

    end

  end

  describe "ignore" do

    let(:mass_operation) { Object.new }
    let(:target_id)      { Object.new }

    before do
      contract.stubs(:mass_operation).returns mass_operation
    end

    it "should pass the id back to the mass operation, add it to the list of ignored targets" do
      mass_operation.expects(:ignored!).with target_id
      contract.ignore target_id
    end
  end

  describe "find" do
    it "should return the target id" do
      target_id = Object.new
      contract.find(target_id).must_equal target_id
    end
  end

  describe "perform" do
    let(:contract) { TestContract.new }
    it "should raise a not implemented error" do
      target = Object.new
      message = begin
                  contract.perform target
                  nil
                rescue StandardError => error
                  error.message
                end
      message.must_equal 'You must implement perform(target) on TestContract'
    end
  end

  describe "data" do

    it "should return the mass_operation data" do
      data = Object.new
      mass_operation = Struct.new(:data).new data
      contract.stubs(:mass_operation).returns mass_operation

      contract.data.must_be_same_as data
    end

  end

end
