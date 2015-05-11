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

end
