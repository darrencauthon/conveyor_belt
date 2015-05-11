require_relative '../spec_helper'

describe ConveyorBelt::MassOperation do

  describe "id" do

    let(:mass_operation) do
      ConveyorBelt::MassOperation.new({})
    end

    it "should get a unique id" do
      mass_operation.id.nil?.must_equal false
      mass_operation.id.wont_equal ''
    end

    it "should be the same id each time I ask for it" do
      mass_operation.id.must_equal mass_operation.id
    end

  end

  describe "creating a new operation" do

    describe "with a contract" do

      let(:contract) { TestContract.new }

      describe "and a list of things" do

        let(:list) { ['1', '2', '3'] }

        describe "building the operation" do

          let(:result) do
            ConveyorBelt::MassOperation.with(contract).for(list)
          end

          it "should build the operation" do
            result.is_a?(ConveyorBelt::MassOperation).must_equal true
          end

          it "should have the original contract" do
            result.contract.must_be_same_as contract
          end

          it "should have the original list" do
            result.list.must_equal list
          end

          it "should return the same list each time" do
            result.list.must_be_same_as result.list
          end

          describe "operations" do

            it "should have a list of single operations" do
              result.operations.count.must_equal 3
            end

            it "should be a list of single operations" do
              result.operations
                    .each { |r| r.is_a?(ConveyorBelt::SingleOperation).must_equal true }
            end

            it "should pass the target id of each operation" do
              ids = result.operations.map { |x| x.target_id }
              ids.include?('1').must_equal true
              ids.include?('2').must_equal true
              ids.include?('3').must_equal true
            end

            it "should retain a link to the original contract" do
              result.operations.each do |operation|
                operation.contract.must_be_same_as contract
              end
            end

          end

        end

      end

    end

  end

  describe "execute" do

    let(:mass_operation) { ConveyorBelt::MassOperation.new args }

    let(:args) { { contract: contract, list: list } }

    let(:contract) { Object.new }
    let(:list)     { [random_string] }

    describe "and there is one operation with a target that can be found" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, true) }

      let(:operations) { [operation1] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :start_mass_operation_definition
        contract.stubs :stop_mass_operation_definition
        contract.stubs :execute_single_target
      end

      it "should note that work is to be executed" do
        contract.expects(:start_mass_operation_definition).with mass_operation
        mass_operation.execute
      end

      it "should exeucte the single target" do
        contract.expects(:execute_single_target).with operation1.target_id
        mass_operation.execute
      end

      it "should exeucte the single target AFTER the operation has started" do
        contract.stubs(:execute_single_target).with do |_|
          contract.stubs(:start_mass_operation_definition).raises 'called in the wrong order'
        end
        mass_operation.execute
      end

      it "should stop the mass operation definition" do
        contract.expects(:stop_mass_operation_definition).with mass_operation
        mass_operation.execute
      end

      it "should note when the mass operation definition is over" do
        contract.stubs(:stop_mass_operation_definition).raises 'called in the wrong order'
        contract.stubs(:execute_single_target).with do |_|
          contract.stubs :stop_mass_operation_definition
          true
        end
        mass_operation.execute
      end

    end

    describe "and there is one operation with a target that CANNOT be found" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :start_mass_operation_definition
        contract.stubs :stop_mass_operation_definition
        contract.stubs :execute_single_target
        contract.stubs :ignore_single_target
      end

      it "should note that work is to be executed" do
        contract.expects(:start_mass_operation_definition).with mass_operation
        mass_operation.execute
      end

      it "should NOT execute the target" do
        contract.stubs(:execute_single_target).raises 'should not have been called'
        mass_operation.execute
      end

      it "should note that the missing target has been ignored" do
        contract.expects(:ignore_single_target).with operation1.target_id
        mass_operation.execute
      end

      describe "and its is started again" do
        it "do throw an error that the contract has already been started" do
          mass_operation.execute
          message = begin
                      mass_operation.execute
                      nil
                    rescue RuntimeError => ex
                      ex.message
                    end
          message.must_equal 'This mass operation has already started.'
        end
      end

    end

    describe "and there are two operations" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, true) }
      let(:operation2) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1, operation2] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :start_mass_operation_definition
        contract.stubs :stop_mass_operation_definition
        contract.stubs :execute_single_target
        contract.stubs :ignore_single_target
      end

      it "should note that work is to be executed" do
        contract.expects(:start_mass_operation_definition).with mass_operation
        mass_operation.execute
      end

      it "should execute the found target" do
        contract.expects(:execute_single_target).with operation1.target_id
        mass_operation.execute
      end

      it "should ignore the target that cannot be found" do
        contract.expects(:ignore_single_target).with operation2.target_id
        mass_operation.execute
      end

      it "should not which targets had been considered" do
        mass_operation.execute
        considered = mass_operation.considered.map { |x| x['target_id'] }
        considered.count.must_equal 2
        considered.include? operation1.target_id
        considered.include? operation2.target_id
      end

      it "should track which task each one went through" do
        mass_operation.execute
        considered = mass_operation
                       .considered
                       .select { |x| x['task'] == 'execute_single_target' }
                       .map    { |x| x['target_id'] }
        considered.count.must_equal 1
        considered.include? operation1.target_id

        considered = mass_operation
                       .considered
                       .select { |x| x['task'] == 'ignore_single_target' }
                       .map    { |x| x['target_id'] }
        considered.count.must_equal 1
        considered.include? operation2.target_id
      end

    end

    describe "and there are two operations, both of which have been considered" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, true) }
      let(:operation2) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1, operation2] }

      before do
        mass_operation.stubs(:operations).returns operations
        mass_operation.stubs(:considered).returns [operation1.target_id, operation2.target_id]
      end

      it "do throw an error that the contract has already been started" do
        message = begin
                    mass_operation.execute
                    nil
                  rescue RuntimeError => ex
                    ex.message
                  end
        message.must_equal 'This mass operation has already started.'
      end

    end

  end

end
