require_relative '../spec_helper'

describe ConveyorBelt::SingleOperation do

  let(:operation) { ConveyorBelt::SingleOperation.new(target, contract: contract) }
  let(:contract)  { TestContract.new }
  let(:target)    { random_string }

  describe "determining if the target can be found" do

    describe "and the target exists" do

      let(:actual_target) { Object.new } 

      before do
        contract.stubs(:find).with(target).returns actual_target
      end

      it "should return true" do
        operation.found?.must_equal true
      end

    end

    describe "and the target does not exist" do

      before do
        contract.stubs(:find).with(target).returns nil
      end

      it "should return true" do
        operation.found?.must_equal false
      end

    end

  end

end
