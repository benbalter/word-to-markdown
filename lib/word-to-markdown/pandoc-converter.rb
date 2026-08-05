# frozen_string_literal: true

class WordToMarkdown
  class PandocConverter
    attr_reader :document

    # @param document [WordToMarkdown::Document] The document to convert
    def initialize(document)
      @document = document
    end

    def convert!
      document.raw_html = pandoc.to_html
      #raw_markdown = pandoc.to_markdown # NOTE: Try GFM, CommonMark, or + Extensions
      #document.markdown = document.send(:scrub_whitespace, raw_markdown)
    end

    private

    def pandoc
      require 'pandoc-ruby'
      @pandoc ||= PandocRuby.new([document.path], from: 'docx')
    end
  end
end
