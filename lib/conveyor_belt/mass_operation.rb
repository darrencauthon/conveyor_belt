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

    def considered
      @considered ||= []
    end

    def operations
      @operations ||= list.map { |x| ConveyorBelt::SingleOperation.new(x, contract: contract) }
    end

    def execute
      raise 'This mass operation has already started.' if considered.count > 0
      contract.start_mass_operation self
      @considered = []
      tasks_to_execute.each do |t|
        contract.send t[:task], t[:target_id]
        @considered << { 'target_id' => t[:target_id], 'task' => t[:task].to_s }
      end
    end

    private

    def tasks_to_execute
      operations.map do |operation|
        task = operation.target_found? ? :execute_single_step : :ignore_single_step
        {
          task:      task,
          target_id: operation.target_id,
        }
      end
    end

  end

end
