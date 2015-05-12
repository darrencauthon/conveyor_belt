module ConveyorBelt
  class InMemoryContract < Contract

    attr_reader :target_ids
    attr_reader :mass_operation

    def initialize
      @target_ids = []
    end

    def start_mass_operation_definition mass_operation
      @mass_operation = mass_operation
    end

    def ignore_target _
    end

    def execute_target target_id
      @target_ids << target_id
    end

    def stop_mass_operation_definition mass_operation
      target_ids.each do |target_id|
        operation = mass_operation.operations.select { |o| o.target_id == target_id }.first
        next unless operation
        operation.execute
      end
    end
  end
end
