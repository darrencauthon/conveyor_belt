require_relative '../spec_helper'

describe ConveyorBelt::SingleOperation do

  let(:operation) { ConveyorBelt::SingleOperation.new(target_id, contract: contract) }
  let(:contract)  { TestContract.new }
  let(:target_id) { random_string }

  describe "determining if the target can be found" do

    describe "and the target exists" do

      let(:target) { Object.new } 

      before do
        contract.stubs(:find).with(target_id).returns target
      end

      it "should return true" do
        operation.found?.must_equal true
      end

    end

    describe "and the target does not exist" do

      before do
        contract.stubs(:find).with(target_id).returns nil
      end

      it "should return true" do
        operation.found?.must_equal false
      end

    end

  end

end
