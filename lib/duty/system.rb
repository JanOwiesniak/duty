require 'open3'

module Duty
  class System
    def call(cmd)
      begin
        Open3.capture3(cmd)
      rescue Exception => e
        [nil, e.message, -1]
      end
    end
  end
end
