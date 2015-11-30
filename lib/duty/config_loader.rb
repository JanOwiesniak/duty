require 'yaml'
require 'pathname'

module Duty
  class ConfigLoader
    DUTY_CONFIG_FILENAME = '.duty.yml'

    def initialize(root_directory = nil)
      @root_directory = root_directory
    end

    def load(base_dir)
      return default_config unless path = find_closest_config_file(base_dir)
      load_config_file(path)
    end

    private

    def default_config
      { "tasks" => [] }
    end

    def find_closest_config_file(base_dir)
      candidates = dirs_to_search(base_dir).map do |dir|
        File.join(dir, DUTY_CONFIG_FILENAME)
      end
      candidates.find do |path|
        File.exists?(path)
      end
    end

    def dirs_to_search(base_dir)
      starting_dir = File.expand_path(base_dir)
      dirs_to_search = []
      Pathname.new(starting_dir).ascend do |path|
        break if path.to_s == @root_directory
        dirs_to_search << path.to_s
      end
      dirs_to_search << Dir.home
    end

    def load_config_file(path)
      YAML.load(File.read(path))
    end
  end
end
