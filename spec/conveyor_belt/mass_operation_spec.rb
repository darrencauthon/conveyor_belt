require_relative '../spec_helper'

class TestContract < ConveyorBelt::Contract
end

describe ConveyorBelt::MassOperation do

  describe "creating a new operation" do

    describe "with a contract" do

      let(:contract) { TestContract.new }

      describe "and a list of things" do

        let(:list) { ['1', '2', '3'] }

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

      end

    end

  end

end
