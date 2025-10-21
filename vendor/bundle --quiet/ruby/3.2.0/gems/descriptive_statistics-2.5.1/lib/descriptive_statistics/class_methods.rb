module DescriptiveStatistics

  class << self

    def empty_collection_default_value
      @empty_collection_default_value
    end

    def empty_collection_default_value=(value)
      @empty_collection_default_value = value
      DescriptiveStatistics.instance_methods.each { |m| default_values[m] = value }
    end

    DescriptiveStatistics.instance_methods.each do |m|
      define_method("#{m}_empty_collection_default_value") do
        default_values[m]
      end
      define_method("#{m}_empty_collection_default_value=") do |value|
        default_values[m] = value
      end
    end

    private

    def default_values
      @default_values ||= {}
    end

  end

  DescriptiveStatistics.instance_methods.each do |method|
    module_function method
    public method
  end

end