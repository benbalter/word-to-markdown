module NokogiriStyles
  class Propset
    def initialize(style_string)
      @properties = parse_properties(style_string)
      @mapping    = make_mapping(@properties)
    end

    def to_s
      @properties.
        map { |p| [p[:key], p[:value]].join(': ') }.
        join('; ')
    end

    def [](key)
      property = @mapping[key]
      property.nil? ? nil : property[:value]
    end

    def []=(key, val)
      return self.delete(key) if val.nil?
      property = @mapping[key]
      if property.nil?
        property      = {:key => key}
        @properties  << property
        @mapping[key] = property
      end
      @mapping[key][:value] = val
    end

    def delete(key)
      @mapping.delete(key)
      @properties.reject! { |p| p[:key] == key }
    end

    private
      def parse_property(property_string)
        parts = property_string.split(':', 2)
        return nil if parts.nil?
        return nil if parts.length != 2
        return nil if parts.any? { |s| s.nil? }
        {:key => parts[0].strip, :value => parts[1].strip}
      end

      def parse_properties(style_string)
        style_string.
          split(';').
          reject { |s| s.strip.empty? }.
          map    { |s| parse_property(s) }.
          reject { |s| s.nil? }
      end

      def make_mapping(properties)
        properties.reduce({}) do |accum, property|
          accum[property[:key]] = property
          accum
        end
      end
  end
end
