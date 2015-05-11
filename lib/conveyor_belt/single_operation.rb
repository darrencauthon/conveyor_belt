module ConveyorBelt

  class SingleOperation

    attr_reader :target, :contract

    def initialize target, options = {}
      @target   = target
      @contract = options[:contract]
    end

    def found?
      contract.find(target).nil? == false
    end

  end

end
