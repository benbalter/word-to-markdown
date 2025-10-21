module DescriptiveStatistics
  def descriptive_statistics(&block)
    return { :number => self.number(&block),
             :sum => self.sum(&block),
             :variance => self.variance(&block),
             :standard_deviation => self.standard_deviation(&block),
             :min => self.min(&block),
             :max => self.max(&block),
             :mean => self.mean(&block),
             :mode => self.mode(&block),
             :median => self.median(&block),
             :range => self.range(&block),
             :q1 => self.percentile(25, &block),
             :q2 => self.percentile(50, &block),
             :q3 => self.percentile(75, &block) }
  end
end
