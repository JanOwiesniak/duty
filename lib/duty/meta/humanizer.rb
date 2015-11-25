require 'duty/registry'

module Duty
  module Meta
    class Humanizer
      def task(klass)
        klass.to_s.
          gsub(/([A-Z])/, '-\1').
          split('-').
          reject(&:empty?).
          map(&:downcase).
          join('-').
          split('::').
          last.
          gsub(/^-/,'')
      end
    end
  end
end
