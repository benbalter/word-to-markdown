require 'reverse_markdown'
require 'descriptive_statistics'

class WordToMarkdown

  attr_reader :doc
  FONT_SIZE_REGEX = /\bfont-size:\s?([0-9\.]+)pt;?\b/
  H_STEP = 100/6
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

  def semanticize!
    # Convert unnumbered list paragraphs to actual unnumbered lists
    @doc.css(".#{LI_SELECTORS.join(",.")}").each { |node| node.node_name = "li" }
  end

  def scrub_whitespace(string)
    string.sub!(/\A[[:space:]]+/,'')                # leading whitespace
    string.sub!(/[[:space:]]+\z/,'')                # trailing whitespace
    string.gsub!(/\n\n \n\n/,"\n\n")                # Quadruple line breaks
    string.gsub!(/^([0-9]+)\.[[:space:]]*/,"\\1. ") # Numbered lists
    string.gsub!(/^-[[:space:]]*/,"- ")             # Unnumbered lists
    string
  end

  def to_s
    @markdown ||= scrub_whitespace(ReverseMarkdown.parse(@doc.to_html))
  end

  def font_sizes
    @font_sizes ||= begin
      sizes = []
      @doc.css("[style]").each do |element|
        match = FONT_SIZE_REGEX.match element.attr("style")
        sizes.push match[1].to_i unless match.nil?
      end
      sizes
    end
  end

  def h(n)
    font_sizes.percentile (6-n) * H_STEP
  end

  def h1
    h(1)
  end

  def h2
    h(2)
  end

  def h3
    h(3)
  end

  def h4
    h(4)
  end

  def h5
    h(5)
  end
end
