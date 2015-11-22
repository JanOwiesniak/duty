module Duty
  module Tasks
    class Test < Base
      def valid?
        !!@arguments[0]
      end

      def execute
        if @arguments[0] == 'shell'
          sh('pwd','First shell command')
          sh('boom','Second shell command')
          sh('pwd','Third shell command')
        else
          ruby(Proc.new{},'First ruby command')
          ruby(Proc.new{ raise RuntimeError.new },'Second ruby command')
          ruby(Proc.new{},'Third ruby command')
        end
      end
    end
  end
end
