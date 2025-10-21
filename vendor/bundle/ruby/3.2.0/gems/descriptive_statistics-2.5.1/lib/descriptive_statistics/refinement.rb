require "descriptive_statistics/safe"

module DescriptiveStatistics

  module Refinement

    def self.new(*klasses)
      refinement_module = Module.new

      klasses.each do |klass|

        refinement_module.instance_eval do

          refine klass do

            DescriptiveStatistics.instance_methods.each do |name|
              method = DescriptiveStatistics.instance_method(name)
              define_method(name, method)
            end

          end

        end

      end

      return refinement_module

    end

  end

end