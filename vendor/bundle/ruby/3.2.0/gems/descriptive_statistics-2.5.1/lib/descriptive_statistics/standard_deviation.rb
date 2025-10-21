module DescriptiveStatistics
  def standard_deviation(collection = self, &block)
    values = Support::convert(collection, &block)
    return DescriptiveStatistics.standard_deviation_empty_collection_default_value if values.empty?

    Math.sqrt(values.variance)
  end
end
