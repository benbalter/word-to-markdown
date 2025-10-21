module Enumerable
  include DescriptiveStatistics

  DescriptiveStatistics.instance_methods.each do |name|
    method = DescriptiveStatistics.instance_method(name)
    define_method(name, method)
  end

end
