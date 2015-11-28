module Duty
  module IO
    module CLI
      class Input
        def initialize(args)
          @args = [args].flatten
        end

        def[](index)
          @args[index]
        end

        def task_name
          task, *rest = @args
          task
        end

        def task_input
          task, *rest = @args
          rest
        end

        def drop(index)
          @args.drop(1)
        end

        def join(seperator='')
          @args.join(seperator)
        end

        def verbose?
          @args.include?('-v') || @args.include?('--verbose')
        end

        def completion?
          @args.first == '--cmplt'
        end

        def help?
          @args.empty? || @args == %w(-h) || @args == %w(--help)
        end
      end

      class Output
        def initialize(stdout, stderr)
          @stdout = stdout
          @stderr = stderr
        end

        def print(*args)
          @stdout.puts(*args)
        end

        def error(*args)
          @stderr.puts(*args)
        end
      end
    end
  end
end
