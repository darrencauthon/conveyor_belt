module ConveyorBelt

  class Contract

    attr_reader :mass_operation

    def perform target
      raise "You must implement perform(target) on #{self.class}"
    end

    def find target_id
      target_id
    end

    def start_mass_operation_definition mass_operation
      @mass_operation = mass_operation
    end

    def stop_mass_operation_definition mass_operation
      mass_operation.examined_list.select { |x| x['task'].to_s == 'mark_for_execution' }
      .map { |x| x['target_id'] }
        .each do |target_id|
        operation = mass_operation.operations.select { |o| o.target_id == target_id }.first
        operation.execute
      end
      mass_operation.examined_list.select { |x| x['task'].to_s == 'mark_for_ignoring' }
      .map { |x| x['target_id'] }
        .each do |target_id|
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

    def data
      mass_operation.data
    end

  end

end
