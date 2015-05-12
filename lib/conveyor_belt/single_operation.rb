module ConveyorBelt

  class SingleOperation

    attr_reader :target_id, :contract

    def initialize target_id, options = {}
      @target_id = target_id
      @contract  = options[:contract]
    end

    def target_found?
      target.nil? == false
    end

    def target
      @target ||= contract.find target_id
    end

    def execute
      contract.execute target_id
    end

  end

end
