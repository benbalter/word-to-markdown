# frozen_string_literal: true

class WordToMarkdown
  class Converter
    attr_reader :document

    # Number of headings to guess, e.g., h6
    HEADING_DEPTH = 6

    # Percentile step for eaceh eheading
    HEADING_STEP = 100 / HEADING_DEPTH

    # Minimum heading size
    MIN_HEADING_SIZE = 20

    # Unicode bullets to strip when processing
    UNICODE_BULLETS = ['○', 'o', '●', "\u2022", '\\p{C}'].freeze

    # @param document [WordToMarkdown::Document] The document to convert
    def initialize(document)
      @document = document
    end

    # Convert the document
    #
    # Note: this action is destructive!
    def convert!
      # Fonts and headings
      semanticize_font_styles!
      semanticize_headings!

      # Tables
      remove_paragraphs_from_tables!
      semanticize_table_headers!

      # list items
      remove_paragraphs_from_list_items!
      remove_unicode_bullets_from_list_items!
      remove_whitespace_from_list_items!
      remove_numbering_from_list_items!
    end

    # @return [Array<Nokogiri::Node>] Return an array of Nokogiri Nodes that are implicit headings
    def implicit_headings
      process_styled_elements unless @implicit_headings
      @implicit_headings
    end

    # @return [Array<Integer>] An array of font-sizes for implicit headings in the document
    def font_sizes
      process_styled_elements unless @font_sizes
      @font_sizes
    end

    # Process styled elements once to populate both implicit_headings and font_sizes
    # This optimization combines two separate iterations into one
    def process_styled_elements
      headings = []
      sizes = []

      @document.tree.css('[style]').each do |element|
        font_size = element.font_size
        unless font_size.nil?
          sizes.push font_size.round(-1)
          headings.push element if font_size >= MIN_HEADING_SIZE
        end
      end

      @implicit_headings = headings
      @font_sizes = sizes.uniq.sort.extend(DescriptiveStatistics)
    end

    # Given a Nokogiri node, guess what heading it represents, if any
    #
    # @param node [Nokigiri::Node] the nokigiri node
    # @return [String, nil] the heading tag (e.g., H1), or nil
    def guess_heading(node)
      return nil if node.font_size.nil?

      [*1...HEADING_DEPTH].each do |heading|
        return "h#{heading}" if node.font_size >= h(heading)
      end
      nil
    end

    # Minimum font size required for a given heading
    # e.g., H(2) would represent the minimum font size of an implicit h2
    #
    # @param num [Integer] the heading number, e.g., 1, 2
    #
    # @return [Integer] the minimum font size
    def h(num)
      font_sizes.percentile(((HEADING_DEPTH - 1) - num) * HEADING_STEP)
    end

    # Convert span-based font styles to `strong`s and `em`s
    def semanticize_font_styles!
      @document.tree.css('span').each do |node|
        if node.bold?
          node.node_name = 'strong'
        elsif node.italic?
          node.node_name = 'em'
        end
      end
    end

    # Remove top-level paragraphs from table cells
    def remove_paragraphs_from_tables!
      @document.tree.css('td > p').each { |node| node.node_name = 'span' }
    end

    # Remove top-level paragraphs from list items
    def remove_paragraphs_from_list_items!
      @document.tree.css('li > p').each { |node| node.node_name = 'span' }
    end

    # Remove prepended unicode bullets from list items
    def remove_unicode_bullets_from_list_items!
      list_item_spans.each do |span|
        span.inner_html = span.inner_html.gsub(/^([#{UNICODE_BULLETS.join}]+)/, '')
      end
    end

    # Remove prepended numbers from list items
    def remove_numbering_from_list_items!
      list_item_spans.each do |span|
        span.inner_html = span.inner_html.gsub(/^[a-zA-Z0-9]+\./m, '')
      end
    end

    # Remvoe whitespace from list items
    def remove_whitespace_from_list_items!
      @document.tree.css('li span').each { |span| span.inner_html.strip! }
    end

    private

    # Memoize the list item span selector to avoid repeated major version checks
    def list_item_spans
      @list_item_spans ||= begin
        path = WordToMarkdown.soffice.major_version == '5' ? 'li span span' : 'li span'
        @document.tree.css(path)
      end
    end

    # Convert table headers to `th`s2
    def semanticize_table_headers!
      @document.tree.css('table tr:first-child > td').each { |node| node.node_name = 'th' }
    end

    # Try to guess heading where implicit bassed on font size
    def semanticize_headings!
      implicit_headings.each do |element|
        heading = guess_heading element
        element.node_name = heading unless heading.nil?
      end
    end
  end
end
