module Duty
  module Tasks
    class Registry
      COMMAND_NAMESPACE = Duty::Tasks

      def initialize(additional_commands_dir = nil)
        @core_commands_dir = __dir__
        @additional_commands_dir = additional_commands_dir
      end

      def all
        command_names = COMMAND_NAMESPACE.constants - [:Base]
        command_names.reduce([]) do |command_classes, command_name|
          command_class = COMMAND_NAMESPACE.const_get(command_name)
          command_classes << command_class if valid?(command_class)
          command_classes
        end
      end

      def valid?(command_class)
        command_class.respond_to?(:superclass) &&
        command_class.superclass == Duty::Tasks::Base
      end

      def require_all
        require_commands(@core_commands_dir)
        require_commands(@additional_commands_dir) if @additional_commands_dir
      end

      def require_commands(dir)
        command_files =File.expand_path(File.join(dir, "*.rb"))
        Dir[command_files].each do |path|
          require path.gsub(/(\.rb)$/, '')
        end
      end
    end
  end
end
