module DescriptiveStatistics
  def sum(collection = self, &block)
    values = Support::convert(collection, &block)
    return DescriptiveStatistics.sum_empty_collection_default_value if values.empty?

    return values.reduce(:+)
  end
end
