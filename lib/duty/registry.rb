module Duty
  class Registry
    def self.load(plugins = [])
      new(plugins).tap {|registry| registry.require_tasks }
    end

    attr_reader :plugins
    def initialize(plugins)
      @plugins = plugins
    end

    def require_tasks
      plugins.each {|plugin| plugin.require_tasks }
    end
  end
end
