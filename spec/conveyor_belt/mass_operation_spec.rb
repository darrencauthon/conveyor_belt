require_relative '../spec_helper'

describe ConveyorBelt::MassOperation do

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
        contract.stubs :start_mass_operation
        contract.stubs :execute_single_step
      end

      it "should note that work is to be executed" do
        contract.expects(:start_mass_operation).with mass_operation
        mass_operation.execute
      end

      it "should exeucte the single step" do
        contract.expects(:execute_single_step).with operation1.target_id
        mass_operation.execute
      end

      it "should exeucte the single step AFTER the operation has started" do
        contract.stubs(:execute_single_step).with do |_|
          contract.stubs(:start_mass_operation).raises 'called in the wrong order'
        end
        mass_operation.execute
      end

    end

    describe "and there is one operation with a target that CANNOT be found" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :start_mass_operation
        contract.stubs :execute_single_step
        contract.stubs :ignore_single_step
      end

      it "should note that work is to be executed" do
        contract.expects(:start_mass_operation).with mass_operation
        mass_operation.execute
      end

      it "should NOT execute the step" do
        contract.stubs(:execute_single_step).raises 'should not have been called'
        mass_operation.execute
      end

      it "should note that the missing step has been ignored" do
        contract.expects(:ignore_single_step).with operation1.target_id
        mass_operation.execute
      end

    end

    describe "and there are two operations" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, true) }
      let(:operation2) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1, operation2] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :start_mass_operation
        contract.stubs :execute_single_step
        contract.stubs :ignore_single_step
      end

      it "should note that work is to be executed" do
        contract.expects(:start_mass_operation).with mass_operation
        mass_operation.execute
      end

      it "should execute the found step" do
        contract.expects(:execute_single_step).with operation1.target_id
        mass_operation.execute
      end

      it "should ignore the step that cannot be found" do
        contract.expects(:ignore_single_step).with operation2.target_id
        mass_operation.execute
      end

    end

  end

end
