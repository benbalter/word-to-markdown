# frozen_string_literal: true

class WordToMarkdown
  class Document
    class NotFoundError < StandardError; end

    class ConversionError < StandardError; end

    class UnsupportedFormatError < StandardError; end

    attr_reader :path, :tmpdir, :import_filter

    # @param path [string] Path to the Word document
    # @param tmpdir [string] Path to a working directory to use
    def initialize(path, tmpdir = nil)
      @path = File.expand_path path, Dir.pwd
      raise NotFoundError, "File #{@path} does not exist" unless File.exist?(@path)

      @import_filter = InputFormat.filter_for(@path)
      raise UnsupportedFormatError, "File #{@path} is not a Word document (.docx or .doc)" if @import_filter.nil?

      @own_tmpdir = tmpdir.nil?
      @tmpdir = tmpdir || Dir.mktmpdir
    end

    # @return [String] the document's extension
    def extension
      File.extname path
    end

    # @return [Nokogiri::Document]
    def tree
      @tree ||= begin
        tree = Nokogiri::HTML(normalized_html)
        tree.css('title').remove
        tree
      end
    end

    # @return [String] the html representation of the document
    def html
      UrlScrubber.scrub!(tree)
      tree.to_html.gsub("</li>\n", '</li>')
    end

    # @return [String] the markdown representation of the document
    def markdown
      @markdown ||= scrub_whitespace(ReverseMarkdown.convert(html, WordToMarkdown::REVERSE_MARKDOWN_OPTIONS))
    end
    alias to_s markdown

    # Determine the document encoding
    #
    # @return [String] the encoding, defaulting to "UTF-8"
    def encoding
      match = raw_html.encode('UTF-8', invalid: :replace, replace: '').match(/charset=([^"]+)/)
      if match
        match[1].sub('macintosh', 'MacRoman')
      else
        'UTF-8'
      end
    end

    private

    # Perform pre-processing normalization
    #
    # @return [String] the normalized html
    def normalized_html
      html = raw_html.dup.force_encoding(encoding)
      html = html.encode('UTF-8', invalid: :replace, replace: '')
      html = Premailer.new(html, with_html_string: true, input_encoding: 'UTF-8').to_inline_css
      html.gsub!(/\n|\r/, ' ')  # Remove linebreaks
      html.gsub!(/“|”/, '"')    # Straighten curly double quotes
      html.gsub!(/‘|’/, "'")    # Straighten curly single quotes
      html.gsub!(/>\s+</, '><') # Remove extra whitespace between tags
      html
    end

    # Perform post-processing normalization of certain Word quirks
    #
    # @param string [String] the markdown representation of the document
    #
    # @return [String] the normalized markdown
    def scrub_whitespace(string)
      string = string.dup
      string.gsub!('&nbsp;', ' ')       # HTML encoded spaces
      string.sub!(/\A[[:space:]]+/, '') # document leading whitespace
      string.sub!(/[[:space:]]+\z/, '') # document trailing whitespace
      string.gsub!(/( +)$/, '')         # line trailing whitespace
      string.gsub!("\n\n\n\n", "\n\n")  # Quadruple line breaks
      string.delete!(' ')               # Unicode non-breaking spaces, injected as tabs
      string.gsub!(/\*\*\ +(?!\*|_)([[:punct:]])/, '**\1') # Remove extra space after bold
      string
    end

    # @return [String] the path to the intermediary HTML document
    def dest_path
      File.expand_path("#{File.basename(path, '.*')}.html", tmpdir)
    end

    # @return [String] the unnormalized HTML representation
    def raw_html
      @raw_html ||= begin
        WordToMarkdown.run_command '--headless', "--infilter=#{import_filter}", '--convert-to', filter, path, '--outdir', tmpdir
        raise ConversionError, "Failed to convert #{path}" unless File.exist?(dest_path)

        html = File.read dest_path
        File.delete dest_path
        html
      ensure
        remove_tmpdir
      end
    end

    # Remove the working directory if we created it and nothing else is in it.
    # Non-empty directories are kept, since LibreOffice may have written
    # images there that the markdown references.
    def remove_tmpdir
      Dir.rmdir(tmpdir) if @own_tmpdir && Dir.empty?(tmpdir)
    end

    # @return [String] the LibreOffice filter to use for export
    def filter
      if WordToMarkdown.soffice.major_version == '5'
        'html:XHTML Writer File:UTF8'
      else
        'html'
      end
    end
  end
end
