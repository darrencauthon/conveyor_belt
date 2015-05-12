module ConveyorBelt

  class Contract

    attr_reader :mass_operation

    def find target_id
      target_id
    end

    def start_mass_operation_definition mass_operation
      @mass_operation = mass_operation
    end

    def target_ids_to_execute
      @target_ids_to_execute ||= []
    end

    def target_ids_to_ignore
      @target_ids_to_ignore ||= []
    end

    def mark_for_ignoring target_id
      target_ids_to_ignore << target_id
    end

    def mark_for_execution target_id
      target_ids_to_execute << target_id
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
      mass_operation.succeeded! target_id
    end

    def ignore target_id
      mass_operation.ignored! target_id
    end

    def perform target
      raise "You must implement perform(target) on #{self.class}"
    end

  end

end
