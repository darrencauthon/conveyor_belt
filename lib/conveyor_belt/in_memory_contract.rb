module ConveyorBelt

  class InMemoryContract < Contract

    attr_reader :target_ids_to_execute
    attr_reader :target_ids_to_ignore
    attr_reader :mass_operation

    def initialize
      @target_ids_to_execute = []
      @target_ids_to_ignore  = []
    end

    def start_mass_operation_definition mass_operation
      @mass_operation = mass_operation
    end

    def mark_for_ignoring target_id
      @target_ids_to_ignore << target_id
    end

    def mark_for_execution target_id
      @target_ids_to_execute << target_id
    end

    def stop_mass_operation_definition mass_operation
      target_ids_to_execute.each do |target_id|
        operation = mass_operation.operations.select { |o| o.target_id == target_id }.first
        operation.execute
      end
      target_ids_to_ignore.each do |target_id|
        operation = mass_operation.operations.select { |o| o.target_id == target_id }.first
        operation.ignore
      end
    end

    def execute target_id
      perform find(target_id)
    end

  end

end
