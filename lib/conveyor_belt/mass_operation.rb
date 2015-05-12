require 'json'

module ConveyorBelt

  class MassOperation

    attr_reader :contract, :list, :id

    attr_reader :ignored_ids
    attr_reader :succeeded_ids

    def initialize args
      @contract = args[:contract].present? && args[:contract].is_a?(String) ? args[:contract].constantize.new : args[:contract]
      @list     = args[:list] || []
      @id       = args[:id] || SecureRandom.uuid
      @examined_list = args[:examined_list]
      @ignored_ids = args[:ignored_ids] || []
      @succeeded_ids = args[:succeeded_ids] || []
      @data = HashWithIndifferentAccess.new(args[:data] || {})
    end

    def data
      @data
    end

    def examined_list
      return @examined_list if @examined_list
      @examined_list = []
      tasks_to_execute.each do |t|
        @examined_list << { 'target_id' => t[:target_id], 'task' => t[:task].to_s }
      end
      @examined_list
    end

    def dump
      {
        id:         id,
        contract:   contract.class.to_s,
        list:       list,
        examined_list: examined_list,
        ignored_ids: ignored_ids,
        succeeded_ids: succeeded_ids,
        data: data,
      }.to_json
    end

    def ignored! target_id
      @ignored_ids << target_id
    end

    def succeeded! target_id
      @succeeded_ids << target_id
    end

    def self.load data
      data = JSON.parse data
      new( { contract:   data['contract'],
             list:       data['list'],
             id:         data['id'],
             examined_list: data['examined_list'],
             data: data['data'],
             ignored_ids: data['ignored_ids'],
             succeeded_ids: data['succeeded_ids']} ).tap { |x| x.contract.start_mass_operation_definition x }
    end

    def self.using contract
      Struct.new(:contract).new(contract).tap do |setup|
        def setup.for list
          @list = list
          self
        end

        def setup.with data
          @data = data
          self
        end

        def setup.new
          MassOperation.new(contract: contract, list: (@list || []), data: (@data || {}))
        end
      end
    end

    def operations
      @operations ||= list.map { |x| ConveyorBelt::SingleOperation.new(x, contract: contract) }
    end

    def execute
      contract.start_mass_operation_definition self
      examined_list
      contract.stop_mass_operation_definition self
    end

    private

    def tasks_to_execute
      operations.map do |operation|
        task = operation.target_found? ? :mark_for_execution : :mark_for_ignoring
        {
          task:      task,
          target_id: operation.target_id,
        }
      end
    end

  end

end
