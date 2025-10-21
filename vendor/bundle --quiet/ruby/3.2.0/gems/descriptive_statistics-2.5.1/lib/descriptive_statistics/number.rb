module DescriptiveStatistics
  def number(collection = self, &block)
    values = Support::extract(collection, &block)

    values.to_a.size.to_f
  end
end
