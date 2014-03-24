require 'reverse_markdown'
require 'descriptive_statistics'

class WordToMarkdown

  HEADING_DEPTH = 6 # Number of headings to guess, e.g., h6
  HEADING_STEP = 100/HEADING_DEPTH
  LI_SELECTORS = %w[
    MsoListParagraphCxSpFirst
    MsoListParagraphCxSpMiddle
    MsoListParagraphCxSpLast
  ]

  attr_reader :path, :doc, :html

  # Create a new WordToMarkdown object
  #
  # input - a HTML string or path to an HTML file
  #
  # Returns the WordToMarkdown object
  def initialize(input)
    path = File.expand_path input, Dir.pwd
    if File.exist?(path)
      @html = File.open(path).read
      @path = path
    else
      @path = String
      @html = input
    end
    @html = @html.force_encoding('iso8859-1').encode("UTF-8", :invalid => :replace, :replace => "")
    @doc = Nokogiri::HTML @html
    semanticize!
  end

  def inspect
    "<WordToMarkdown path=\"#{@path}\">"
  end

  def to_s
    @markdown ||= scrub_whitespace(ReverseMarkdown.parse(@doc.to_html))
  end

  def scrub_whitespace(string)
    string.sub!(/\A[[:space:]]+/,'')                # leading whitespace
    string.sub!(/[[:space:]]+\z/,'')                # trailing whitespace
    string.gsub!(/\n\n \n\n/,"\n\n")                # Quadruple line breaks
    string.gsub!(/^([0-9]+)\.[[:space:]]*/,"\\1. ") # Numbered lists
    string.gsub!(/^-[[:space:]á]*/,"- ")             # Unnumbered lists
    string
  end

  # Returns an array of Nokogiri nodes that are implicit headings
  def implicit_headings
    @implicit_headings ||= begin
      headings = []
      @doc.css("[style]").each do |element|
        headings.push element unless element.font_size.nil?
      end
      headings
    end
  end

  # Returns an array of font-sizes for implicit headings in the document
  def font_sizes
    @font_sizes ||= begin
      sizes = []
      implicit_headings.each { |element| sizes.push element.font_size }
      sizes
    end
  end

  # Given a Nokogiri node, guess what heading it represents, if any
  def guess_heading(node)
    return nil if node.font_size == nil
    [*1...HEADING_DEPTH].each do |heading|
      return "h#{heading}" if node.font_size >= h(heading)
    end
    nil
  end

  # Minimum font size required for a given heading
  # e.g., H(2) would represent the minimum font size of an implicit h2
  def h(n)
    font_sizes.percentile ((HEADING_DEPTH-1)-n) * HEADING_STEP
  end

  # Try to make semantic markup explicit where implied by the export
  def semanticize!
    # Convert unnumbered list paragraphs to actual unnumbered lists
    @doc.css(".#{LI_SELECTORS.join(",.")}").each { |node| node.node_name = "li" }

    # Try to guess heading where implicit bassed on font size
    implicit_headings.each do |element|
      heading = guess_heading element
      element.node_name = heading unless heading.nil?
    end
  end
end

module Nokogiri
  module XML
    class Element

      FONT_SIZE_REGEX = /\bfont-size:\s?([0-9\.]+)pt;?\b/

      def font_size
        @font_size ||= begin
          match = FONT_SIZE_REGEX.match attr("style")
          match[1].to_i unless match.nil?
        end
      end
    end
  end
end
