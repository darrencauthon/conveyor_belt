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

    describe "using a contract" do

      let(:contract) { TestContract.new }

      describe "and a list of things" do

        let(:list) { ['1', '2', '3'] }

        describe "building the operation" do

          let(:result) do
            ConveyorBelt::MassOperation.using(contract).for(list).new
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

          describe "with more data" do
            let(:the_key)   { random_string }
            let(:the_value) { random_string }
            let(:the_data)  { { the_key => the_value } }

            let(:result) do
              ConveyorBelt::MassOperation
                .using(contract)
                .with(the_data)
                .for(list)
                .new
            end

            it "should set the data on the mass operation" do
              result.data[the_key].must_equal the_value
            end

          end

          describe "dumping and loading" do
            it "should allow me to deconstruct and reconstruct the mass operation" do
              data = result.dump
              data.is_a?(String).must_equal true
              restored = ConveyorBelt::MassOperation.load data
              restored.is_a? ConveyorBelt::MassOperation
              restored.id.must_equal result.id

              restored.list.must_equal result.list
              restored.examined_list.must_equal result.examined_list
            end

            it "should retain the actual contract used" do
              result.contract.is_a?(TestContract).must_equal true
              restored = ConveyorBelt::MassOperation.load result.dump
              restored.contract.is_a?(TestContract).must_equal true
            end

            it "should retain the mass operation through the contract" do
              restored = ConveyorBelt::MassOperation.load result.dump
              restored.contract.mass_operation.id.must_equal result.id
            end
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

    let(:contract) { TestContract.new }
    let(:list)     { [random_string] }

    describe "and there is one operation with a target that can be found" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, true) }

      let(:operations) { [operation1] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :kick_off_all_pending_operations
      end

      it "should kick off all pending operations" do
        contract.expects(:kick_off_all_pending_operations).with mass_operation
        mass_operation.execute
      end

    end

    describe "and there is one operation with a target that CANNOT be found" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :kick_off_all_pending_operations
      end

    end

    describe "and there are two operations" do

      let(:operation1) { Struct.new(:target_id, :target_found?).new(random_string, true) }
      let(:operation2) { Struct.new(:target_id, :target_found?).new(random_string, false) }

      let(:operations) { [operation1, operation2] }

      before do
        mass_operation.stubs(:operations).returns operations
        contract.stubs :kick_off_all_pending_operations
      end

      it "should not which targets had been examined_list" do
        mass_operation.execute
        examined_list = mass_operation.examined_list.map { |x| x['target_id'] }
        examined_list.count.must_equal 2
        examined_list.include? operation1.target_id
        examined_list.include? operation2.target_id
      end

      it "should track which task each one went through" do
        mass_operation.execute
        examined_list = mass_operation
                       .examined_list
                       .select { |x| x['task'] == 'mark_for_execution' }
                       .map    { |x| x['target_id'] }
        examined_list.count.must_equal 1
        examined_list.include? operation1.target_id

        examined_list = mass_operation
                       .examined_list
                       .select { |x| x['task'] == 'mark_for_ignoring' }
                       .map    { |x| x['target_id'] }
        examined_list.count.must_equal 1
        examined_list.include? operation2.target_id
      end

      describe "dumping and loading" do
        it "should allow me to deconstruct and reconstruct the mass operation" do
          mass_operation.execute

          data = mass_operation.dump
          restored = ConveyorBelt::MassOperation.load data
          restored.examined_list.must_equal mass_operation.examined_list
        end
      end

    end

  end

  describe "ignored!" do

    let(:mass_operation) do
      ConveyorBelt::MassOperation.new( { contract: TestContract.new } )
    end

    it "should default a new mass operation to an empty list of ignored ids" do
      mass_operation.ignored_ids.count.must_equal 0
    end

    it "should allow me to pass a list of ignored ids through the constructor" do
      ignored_ids = Object.new
      mass_operation = ConveyorBelt::MassOperation.new( { contract: TestContract.new, ignored_ids: ignored_ids } )
      mass_operation.ignored_ids.must_be_same_as ignored_ids
    end

    it "should let me add to the ignored list with ignored!" do
      target_id = Object.new
      mass_operation.ignored! target_id
      mass_operation.ignored_ids.count.must_equal 1
      mass_operation.ignored_ids[0].must_be_same_as target_id
    end

    describe "dumping and loading" do
      it "should allow me to deconstruct and reconstruct the mass operation" do
        target_id = random_string
        mass_operation.ignored! target_id

        restored = ConveyorBelt::MassOperation.load mass_operation.dump
        restored.ignored_ids.count.must_equal 1
        restored.ignored_ids[0].must_equal target_id
      end
    end

  end

  describe "succeeded!" do

    let(:mass_operation) do
      ConveyorBelt::MassOperation.new( { contract: TestContract.new } )
    end

    it "should default a new mass operation to an empty list of succeeded ids" do
      mass_operation.succeeded_ids.count.must_equal 0
    end

    it "should allow me to pass a list of succeeded ids through the constructor" do
      succeeded_ids = Object.new
      mass_operation = ConveyorBelt::MassOperation.new( { succeeded_ids: succeeded_ids } )
      mass_operation.succeeded_ids.must_be_same_as succeeded_ids
    end

    it "should let me add to the succeeded list with succeeded!" do
      target_id = Object.new
      mass_operation.succeeded! target_id
      mass_operation.succeeded_ids.count.must_equal 1
      mass_operation.succeeded_ids[0].must_be_same_as target_id
    end

    describe "dumping and loading" do
      it "should allow me to deconstruct and reconstruct the mass operation" do
        target_id = random_string
        mass_operation.succeeded! target_id

        restored = ConveyorBelt::MassOperation.load mass_operation.dump
        restored.succeeded_ids.count.must_equal 1
        restored.succeeded_ids[0].must_equal target_id
      end
    end

  end

  describe "data" do

    let(:the_key)   { random_string }
    let(:the_value) { random_string }
    let(:data)      { { the_key => the_value } }

    let(:mass_operation) do
      ConveyorBelt::MassOperation.new( { data: data, contract: TestContract.new } )
    end

    it "should default to an empty hash" do
      ConveyorBelt::MassOperation.new({}).data.count.must_equal 0
    end

    it "should return the data that was passed in" do
      mass_operation.data[the_key].must_equal the_value
    end

    it "should return an access indifferent hash" do
      mass_operation.data[the_key.to_sym].must_equal the_value
    end

    describe "dumping and loading" do
      it "should allow me to deconstruct and reconstruct the data" do
        data = mass_operation.dump
        restored = ConveyorBelt::MassOperation.load data
        restored.data[the_key].must_equal the_value
      end
    end

  end

end
