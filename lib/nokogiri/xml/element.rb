module Nokogiri
  module XML
    class Element

      # The node's font size
      # Used for guessing heading sizes
      #
      # Returns a float with the font-size
      def font_size
        if styles['font-size']
          styles['font-size'].to_f
        else
          12.to_f
        end
      end

      def bold?
        styles['font-weight'] && styles['font-weight'] == "bold"
      end

      def italic?
        styles['font-style'] && styles['font-style'] == "italic"
      end
    end
  end
end
