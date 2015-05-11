module ConveyorBelt

  class SingleOperation

    attr_reader :target, :contract

    def initialize target, options = {}
      @target   = target
      @contract = options[:contract]
    end

  end

end