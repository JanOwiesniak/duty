require 'open3'

module Duty
  class System
    def call(cmd)
      Open3.capture3(cmd)
    end
  end
end
