require 'set'

module DescriptiveStatistics

  module Support

    def self.convert(from_enumerable, &block)
      extend to_float to_value(to_array(from_enumerable), &block)
    end

    def self.extract(from_enumerable, &block)
      extend to_value(to_array(from_enumerable), &block)
    end

    private

    def self.extend(enumerable)
      enumerable.extend(DescriptiveStatistics)
    end

    def self.to_float(enumerable)
      enumerable.map(&:to_f)
    end

    def self.to_value(enumerable, &block)
      return enumerable unless block_given?
      enumerable.map { |object| yield object }
    end

    def self.to_array(enumerable)
      case enumerable
      when Hash
        enumerable.values.each
      when Set
        enumerable.to_a.each
      else
        enumerable.each
      end
    end

  end

end
