class WordToMarkdown
  class Converter

    attr_reader :document

    HEADING_DEPTH = 6 # Number of headings to guess, e.g., h6
    HEADING_STEP = 100/HEADING_DEPTH
    MIN_HEADING_SIZE = 20

    LI_SELECTORS = %w[
      .MsoListParagraphCxSpFirst
      .MsoListParagraphCxSpMiddle
      .MsoListParagraphCxSpLast
      .MsoListParagraph
      li
    ]

    def initialize(document)
      @document = document
    end

    def convert
      semanticize!
    end

    # Returns an array of Nokogiri nodes that are implicit headings
    def implicit_headings
      @implicit_headings ||= begin
        headings = []
        @document.tree.css("[style]").each do |element|
          headings.push element unless element.font_size.nil? || element.font_size < MIN_HEADING_SIZE
        end
        headings
      end
    end

    # Returns an array of font-sizes for implicit headings in the document
    def font_sizes
      @font_sizes ||= begin
        sizes = []
        @document.tree.css("[style]").each do |element|
          sizes.push element.font_size.round(-1) unless element.font_size.nil?
        end
        sizes.uniq.sort
      end
    end

    # Given a Nokogiri node, guess what heading it represents, if any
    #
    # node - the nokigiri node
    #
    # retuns the heading tag (e.g., H1), or nil
    def guess_heading(node)
      return nil if node.font_size == nil
      [*1...HEADING_DEPTH].each do |heading|
        return "h#{heading}" if node.font_size >= h(heading)
      end
      nil
    end

    # Minimum font size required for a given heading
    # e.g., H(2) would represent the minimum font size of an implicit h2
    #
    # n - the heading number, e.g., 1, 2
    #
    # returns the minimum font size as an integer
    def h(n)
      font_sizes.percentile ((HEADING_DEPTH-1)-n) * HEADING_STEP
    end

    # CSS selector to select non-symantic lists
    def li_selectors
      LI_SELECTORS.join(",")
    end

    # Returns an array of all indented values
    def indents
      @indents ||= @document.tree.css(li_selectors).map{ |el| el.indent }.uniq.sort
    end

    # Determine the indent level given an indent value
    #
    # level - the true indent, e.g., 2.5 (from 2.5em)
    #
    # Returns an integer representing the indent level
    def indent(level)
      indents.find_index level
    end

    # Try to make semantic markup explicit where implied by the export
    def semanticize!

      # Semanticize lists
      indent_level = 0
      @document.tree.css(li_selectors).each do |node|

        next unless node['class']

        # Determine if this is an implicit UL or an implicit OL list item
        if node.classes.include?("MsoListParagraph") || node.content.match(/^[a-zA-Z0-9]+\./)
          list_type = "ol"
        else
          list_type = "ul"
        end

        # calculate indent level
        current_indent = indent(node.indent)

        # Determine parent node for this li, creating it if necessary
        if current_indent > indent_level || indent_level == 0 && node.parent.css(".indent#{current_indent}").empty?
          list = Nokogiri::XML::Node.new list_type, @document.tree
          list.classes = ["list", "indent#{current_indent}"]
          list.parent = node.parent.css(".indent#{current_indent-1} li").last || node.parent
        else
          list = node.parent.css(".indent#{current_indent}").last
        end

        # Note our current nesting depth
        indent_level = current_indent

        # Convert list paragraphs to actual numbered and unnumbered lists
        node.node_name = "li"
        node.parent = list if list

        # Scrub unicode bullets
        span = node.css("span:first")[1]
        if span && span.styles["mso-list"] && span.styles["mso-list"] == "Ignore"
          span.content = span.content[1..-1] unless span.content.match /^\d+\./
        end

        # Convert all pseudo-numbered list items into numbered list items, e.g., ii. => 2.
        node.content = node.content.gsub /^[[:space:] ]+/, ""
        node.content = node.content.gsub /^[a-zA-Z0-9]+\.[[:space:]]+/, ""

      end

      # styling
      @document.tree.css("span").each do |node|
        if node.bold?
          node.node_name = "strong"
        elsif node.italic?
          node.node_name = "em"
        end
      end

      # Try to guess heading where implicit bassed on font size
      implicit_headings.each do |element|
        heading = guess_heading element
        element.node_name = heading unless heading.nil?
      end

      # Removes paragraphs from tables
      @document.tree.search("td p").each { |node| node.node_name = "span" }
    end
  end
end
