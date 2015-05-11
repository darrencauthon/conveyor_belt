module ConveyorBelt

  class MassOperation

    attr_reader :contract, :list

    def initialize args
      @contract = args[:contract]
      @list     = args[:list]
    end

    def self.with contract
      Struct.new(:contract).new(contract).tap do |setup|
        def setup.for list
          MassOperation.new(contract: contract, list: list)
        end
      end
    end

    def operations
      list.map { |x| ConveyorBelt::SingleOperation.new(x, contract: contract) }
    end

  end

end
