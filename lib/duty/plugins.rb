require 'duty/tasks'
require 'yaml'

module Duty
  module Plugins
    def self.load(config)
      config["tasks"].each do |plugin_entry_point|
        path = plugin_entry_point.gsub(/\.rb/,'')
        require path
      end
    end
  end
end
