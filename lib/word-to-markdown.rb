require 'reverse_markdown'
require 'descriptive_statistics'
require 'premailer'
require 'nokogiri'
require 'nokogiri-styles'

class WordToMarkdown

  HEADING_DEPTH = 6 # Number of headings to guess, e.g., h6
  HEADING_STEP = 100/HEADING_DEPTH
  MIN_HEADING_SIZE = 20

  LI_SELECTORS = %w[
    MsoListParagraphCxSpFirst
    MsoListParagraphCxSpMiddle
    MsoListParagraphCxSpLast
    MsoListParagraph
  ]

  attr_reader :path, :doc

  # Create a new WordToMarkdown object
  #
  # input - a HTML string or path to an HTML file
  #
  # Returns the WordToMarkdown object
  def initialize(input)
    path = File.expand_path input, Dir.pwd
    if File.exist?(path)
      html = File.open(path).read
      @path = path
    else
      @path = String
      html = input.to_s
    end
    @doc = Nokogiri::HTML normalize(html)
    semanticize!
  end

  # Perform pre-processing normalization
  #
  # html - the raw html input from the export
  #
  # Returns the normalized html
  def normalize(html)
    encoding = encoding(html)
    html = html.force_encoding(encoding).encode("UTF-8", :invalid => :replace, :replace => "")
    html = Premailer.new(html, :with_html_string => true, :input_encoding => "UTF-8").to_inline_css
    html.gsub! /\<\/?o:[^>]+>/, "" # Strip everything in the office namespace
    html.gsub! /\<\/?w:[^>]+>/, "" # Strip everything in the word namespace
    html.gsub! /\n|\r/," "         # Remove linebreaks
    html.gsub! /“|”/, '"'          # Straighten curly double quotes
    html.gsub! /‘|’/, "'"          # Straighten curly single quotes
    html
  end

  # Pretty print the class in console
  def inspect
    "<WordToMarkdown path=\"#{@path}\">"
  end

  # Returns the markdown representation of the document
  def to_s
    @markdown ||= scrub_whitespace(ReverseMarkdown.parse(html))
  end

  # Returns the html representation of the document
  def html
    doc.to_html.gsub("</li>\n", "</li>")
  end

  # Determine the document encoding
  #
  # html - the raw html export
  #
  # Returns the encoding, defaulting to "UTF-8"
  def encoding(html)
    match = html.encode("UTF-8", :invalid => :replace, :replace => "").match(/charset=([^\"]+)/)
    if match
      match[1].sub("macintosh", "MacRoman")
    else
      "UTF-8"
    end
  end

  # Perform post-processing normalization of certain Word quirks
  #
  # string - the markdown representation of the document
  #
  # Returns the normalized markdown
  def scrub_whitespace(string)
    string.sub!(/\A[[:space:]]+/,'')                # leading whitespace
    string.sub!(/[[:space:]]+\z/,'')                # trailing whitespace
    string.gsub!(/\n\n \n\n/,"\n\n")                # Quadruple line breaks
    string.gsub!(/\u00A0/, "")                      # Unicode non-breaking spaces, injected as tabs
    string
  end

  # Returns an array of Nokogiri nodes that are implicit headings
  def implicit_headings
    @implicit_headings ||= begin
      headings = []
      doc.css("[style]").each do |element|
        headings.push element unless element.font_size.nil? || element.font_size < MIN_HEADING_SIZE
      end
      headings
    end
  end

  # Returns an array of font-sizes for implicit headings in the document
  def font_sizes
    @font_sizes ||= begin
      sizes = []
      doc.css("[style]").each do |element|
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
    ".#{LI_SELECTORS.join(",.")}"
  end

  # Try to make semantic markup explicit where implied by the export
  def semanticize!

    # Semanticize lists
    indent_level = 0
    doc.css(li_selectors).each do |node|

      # Determine if this is an implicit UL or an implicit OL list item
      if node.classes.include?("MsoListParagraph") || node.content.match(/^[a-zA-Z0-9]+\./)
        list_type = "ol"
      else
        list_type = "ul"
      end

      # Determine parent node for this li, creating it if necessary
      if node.indent > indent_level
        list = Nokogiri::XML::Node.new list_type, @doc
        list.classes = ["list", "indent#{node.indent}"]
        if node.indent == 1
          list.parent = node.parent
        else
          list.parent = node.parent.css(".indent#{node.indent-1} li").last
        end
      else
        list = node.parent.css(".indent#{node.indent}").last
      end

      # Note our current nesting depth
      indent_level = node.indent

      # Convert list paragraphs to actual numbered and unnumbered lists
      node.node_name = "li"
      node.parent = list

      # Scrub unicode bullets
      span = node.css("span:first")[1]
      if span && span.styles["mso-list"] && span.styles["mso-list"] == "Ignore"
        span.content = span.content[1..-1] unless span.content.match /^\d+\./
      end

      # Convert all pseudo-numbered list items into numbered list items, e.g., ii. => 2.
      node.content = node.content.gsub /^[[:space:] ]+/, ""
      node.content = node.content.gsub /^[a-zA-Z0-9]+\.[[:space:]]+/, ""

    end

    # Try to guess heading where implicit bassed on font size
    implicit_headings.each do |element|
      heading = guess_heading element
      element.node_name = heading unless heading.nil?
    end

    # Removes paragraphs from tables
    doc.search("td p").each { |node| node.node_name = "span" }
  end
end

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
    end
  end
end
