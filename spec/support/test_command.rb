module Duty
  module Tasks
    class Test < Base
      def execute
        if sequential? 
          shell_commands if shell?
          ruby_commands if ruby?
        end

        if parallel? 
          parallel { shell_commands }
          parallel { ruby_commands }
        end
      end

      def valid?
        !!test_type
      end

      private

      def sequential?
        test_type == 'sequential'
      end

      def parallel?
        test_type == 'parallel'
      end

      def test_type
        @arguments[0]
      end

      def ruby?
        test_command == 'ruby'
      end

      def shell?
        test_command == 'shell'
      end

      def test_command
        @arguments[1]
      end

      def shell_commands
        sh {}
        sh("First #{test_type} shell command") { 'pwd' }
        sh("Second #{test_type} shell command") { 'boom' }
        sh("Third #{test_type} shell command") { 'pwd' }
      end

      def ruby_commands
        ruby {}
        ruby("First #{test_type} ruby command") {}
        ruby("Second #{test_type} ruby command") { raise RuntimeError.new }
        ruby("Third #{test_type} ruby command") {}
      end
    end
  end
end
