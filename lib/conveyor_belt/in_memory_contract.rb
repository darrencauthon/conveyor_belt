module ConveyorBelt
  class InMemoryContract < Contract

    attr_reader :target_ids

    def initialize
      @target_ids = []
    end

    def start_mass_operation_definition _
    end

    def ignore_target _
    end

    def execute_target target_id
      @target_ids << target_id
    end
  end
end
