module DescriptiveStatistics
  def range(collection = self, &block)
    values = Support::convert(collection, &block)
    return DescriptiveStatistics.range_empty_collection_default_value if values.empty?

    values.max - values.min
  end
end
