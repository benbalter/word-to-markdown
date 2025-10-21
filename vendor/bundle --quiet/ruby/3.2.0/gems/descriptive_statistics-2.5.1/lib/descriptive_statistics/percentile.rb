module DescriptiveStatistics
  def percentile(p, collection = self, &block)
    values = Support::convert(collection, &block)

    return DescriptiveStatistics.percentile_empty_collection_default_value if values.empty?
    return values.first if values.size == 1

    values.sort!
    return values.last if p == 100
    rank = p / 100.0 * (values.size - 1)
    lower, upper = values[rank.floor,2]
    lower + (upper - lower) * (rank - rank.floor)
  end
end
