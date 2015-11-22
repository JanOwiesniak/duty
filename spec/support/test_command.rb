module Duty
  module Tasks
    class Test < Base
      def valid?
        !!@arguments[0]
      end

      def execute
        if @arguments[0] == 'shell'
          sh {}
          sh('First shell command') { 'pwd' }
          sh('Second shell command') { 'boom' }
          sh('Third shell command') { 'pwd' }
        else
          ruby {}
          ruby('First ruby command') {}
          ruby('Second ruby command') { raise RuntimeError.new }
          ruby('Third ruby command') {}
        end
      end
    end
  end
end
