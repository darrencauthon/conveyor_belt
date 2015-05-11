require_relative '../spec_helper'

describe ConveyorBelt::SingleOperation do

  let(:operation) { ConveyorBelt::SingleOperation.new(target_id, contract: contract) }
  let(:contract)  { TestContract.new }
  let(:target_id) { random_string }

  describe "getting the target" do

    let(:target) { Object.new }

    before { contract.stubs(:find).with(target_id).returns target }

    it "should return the target returned from the contract" do
      operation.target.must_be_same_as target
    end

    it "should return the same operation each time" do
      contract.stubs(:find).with do |id|
        contract.stubs(:find).raises 'only once please'
      end.returns target
      operation.target.must_be_same_as operation.target
    end

  end

  describe "determining if the target can be found" do

    describe "and the target exists" do

      let(:target) { Object.new } 

      before { operation.stubs(:target).returns target }

      it "should return true" do
        operation.target_found?.must_equal true
      end

    end

    describe "and the target does not exist" do

      before { operation.stubs(:target).returns nil }

      it "should return true" do
        operation.target_found?.must_equal false
      end

    end

  end


end
