module Duty
  module Commands
    module Registry
      COMMAND_NAMESPACE = Duty::Commands

      class << self
        attr_accessor :commands

        def all
          all_names = COMMAND_NAMESPACE.constants - [:Base]
          all_names.reduce([]) do |commands, name|
            command_class = COMMAND_NAMESPACE.const_get(name)
            commands << command_class if command?(command_class)
            commands
          end
        end

        def command?(command_class)
          command_class.respond_to?(:superclass) &&
          command_class.superclass == Duty::Commands::Base
        end

        def require_all
          Dir[command_files].each do |path|
            require path.gsub(/(\.rb)$/, '')
          end
        end

        def command_dir
          __dir__
        end

        def command_files
          File.expand_path(File.join(command_dir, "*.rb"))
        end
      end
    end
  end
end
