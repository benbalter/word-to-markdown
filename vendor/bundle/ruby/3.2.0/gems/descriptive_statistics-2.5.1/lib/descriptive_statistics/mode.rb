module DescriptiveStatistics
  def mode(collection = self, &block)
    values = Support::extract(collection, &block)
    return if values.to_a.empty?

    values
      .group_by { |e| e }
      .values
      .max_by(&:size)
      .first
  end
end
