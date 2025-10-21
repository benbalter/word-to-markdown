require 'delegate'

module DescriptiveStatistics

  class Stats < SimpleDelegator
    include DescriptiveStatistics
  end

end
