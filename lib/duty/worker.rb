module Duty
  class Worker
    def initialize(commands)
      @commands = commands
      @processed = []
    end

    def execute
      @commands.each.with_index do |command, index|
        @processed << command
        next if previous_command_error?(index)
        command.execute
      end
    end

    def processed
      @processed
    end

    private

    def previous_command_error?(current_index)
      if current_index > 0
        previous_index = current_index - 1
        @commands[previous_index].error?
      end
    end
  end
end
