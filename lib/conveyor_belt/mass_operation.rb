require 'json'

module ConveyorBelt

  class MassOperation

    attr_reader :contract, :list, :id, :considered

    def initialize args
      @contract = args[:contract]
      @list     = args[:list]
      @id       = args[:id] || SecureRandom.uuid
      @considered = args[:considered] || []
    end

    def dump
      {
        id:         id,
        contract:   contract.class.to_s,
        list:       list,
        considered: considered,
      }.to_json
    end

    def self.load data
      data = JSON.parse data
      new( { contract:   data['contract'],
             list:       data['list'],
             id:         data['id'],
             considered: data['considered'] } )
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
      raise 'This mass operation has already started.' if considered.count > 0
      contract.start_mass_operation_definition self
      @considered = []
      tasks_to_execute.each do |t|
        contract.send t[:task], t[:target_id]
        @considered << { 'target_id' => t[:target_id], 'task' => t[:task].to_s }
      end
      contract.stop_mass_operation_definition self
    end

    private

    def tasks_to_execute
      operations.map do |operation|
        task = operation.target_found? ? :execute_single_operation : :ignore_single_operation
        {
          task:      task,
          target_id: operation.target_id,
        }
      end
    end

  end

end
