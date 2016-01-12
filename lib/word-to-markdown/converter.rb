# encoding: utf-8
class WordToMarkdown
  class Converter
    attr_reader :document

    HEADING_DEPTH = 6 # Number of headings to guess, e.g., h6
    HEADING_STEP = 100 / HEADING_DEPTH
    MIN_HEADING_SIZE = 20
    UNICODE_BULLETS = ['○', 'o', '●', "\u2022", '\\p{C}']

    def initialize(document)
      @document = document
    end

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

    # Returns an array of Nokogiri nodes that are implicit headings
    def implicit_headings
      @implicit_headings ||= begin
        headings = []
        @document.tree.css('[style]').each do |element|
          headings.push element unless element.font_size.nil? || element.font_size < MIN_HEADING_SIZE
        end
        headings
      end
    end

    # Returns an array of font-sizes for implicit headings in the document
    def font_sizes
      @font_sizes ||= begin
        sizes = []
        @document.tree.css('[style]').each do |element|
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
      return nil if node.font_size.nil?
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
      font_sizes.percentile(((HEADING_DEPTH - 1) - n) * HEADING_STEP)
    end

    def semanticize_font_styles!
      @document.tree.css('span').each do |node|
        if node.bold?
          node.node_name = 'strong'
        elsif node.italic?
          node.node_name = 'em'
        end
      end
    end

    def remove_paragraphs_from_tables!
      @document.tree.search('td p').each { |node| node.node_name = 'span' }
    end

    def remove_paragraphs_from_list_items!
      @document.tree.search('li p').each { |node| node.node_name = 'span' }
    end

    def remove_unicode_bullets_from_list_items!
      path = WordToMarkdown.soffice.major_version == '5' ? 'li span span' : 'li span'
      @document.tree.search(path).each do |span|
        span.inner_html = span.inner_html.gsub(/^([#{UNICODE_BULLETS.join("")}]+)/, '')
      end
    end

    def remove_numbering_from_list_items!
      path = WordToMarkdown.soffice.major_version == '5' ? 'li span span' : 'li span'
      @document.tree.search(path).each do |span|
        span.inner_html = span.inner_html.gsub(/^[a-zA-Z0-9]+\./m, '')
      end
    end

    def remove_whitespace_from_list_items!
      @document.tree.search('li span').each { |span| span.inner_html.strip! }
    end

    def semanticize_table_headers!
      @document.tree.search('table tr:first td').each { |node| node.node_name = 'th' }
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
