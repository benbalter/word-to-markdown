require 'reverse_markdown'
require 'descriptive_statistics'

class WordToMarkdown

  attr_reader :doc
  HEADING_DEPTH = 6
  HEADING_STEP = 100/HEADING_DEPTH
  LI_SELECTORS = %w[
    MsoListParagraphCxSpFirst
    MsoListParagraphCxSpMiddle
    MsoListParagraphCxSpLast
  ]

  attr_reader :path
  attr_accessor :html, :doc

  def initialize(path)
    @path = path
    @html = File.open(@path).read.encode("UTF-8", :invalid => :replace, :replace => "")
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
    string.gsub!(/^-[[:space:]]*/,"- ")             # Unnumbered lists
    string
  end

  def implicit_headings
    @implicit_headings ||= begin
      headings = []
      @doc.css("[style]").each do |element|
        headings.push element unless element.font_size.nil?
      end
      headings
    end
  end

  def font_sizes
    @font_sizes ||= begin
      sizes = []
      implicit_headings.each { |element| sizes.push element.font_size }
      sizes
    end
  end

  def guess_heading(node)
    return nil if node.font_size == nil
    [*1...HEADING_DEPTH].each do |heading|
      return "h#{heading}" if node.font_size >= h(heading)
    end
    nil
  end

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
