module Nokogiri
  module XML
    class Element

      def indent
        if styles['mso-list']
          styles['mso-list'].split(" ")[1].sub("level","").to_i
        else
          (left_margin / 0.5).to_i
        end
      end

      # The node's left-margin
      # Used for parsing nested Lis
      #
      # Returns a float with the left margin
      def left_margin
        if styles['margin-left']
          styles['margin-left'].to_f
        elsif styles['margin']
          styles['margin'].split(" ").last.to_f
        else
          0
        end
      end

      # The node's font size
      # Used for guessing heading sizes
      #
      # Returns a float with the font-size
      def font_size
        styles['font-size'].to_f if styles['font-size']
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
