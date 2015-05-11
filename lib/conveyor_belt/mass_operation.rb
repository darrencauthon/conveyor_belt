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
      @operations ||= list.map { |x| ConveyorBelt::SingleOperation.new(x, contract: contract) }
    end

    def execute
      contract.start_mass_operation self
      tasks = operations.map do |operation|
                task = operation.target_found? ? :execute_single_step : :ignore_single_step
                {
                  task:      task,
                  target_id: operation.target_id,
                }
              end
      tasks.each { |t| contract.send t[:task], t[:target_id] }
    end

  end

end
