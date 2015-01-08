require 'reverse_markdown'
require 'descriptive_statistics'
require 'premailer'
require 'nokogiri'
require 'nokogiri-styles'
require 'tmpdir'
require_relative 'word-to-markdown/version'
require_relative 'word-to-markdown/document'
require_relative 'word-to-markdown/converter'
require_relative 'nokogiri/xml/element'

class WordToMarkdown

  attr_reader :document, :converter

  REVERSE_MARKDOWN_OPTIONS = {
    unknown_tags: :bypass,
    github_flavored: true
  }

  # Create a new WordToMarkdown object
  #
  # input - a HTML string or path to an HTML file
  #
  # Returns the WordToMarkdown object
  def initialize(path, tmpdir = nil)
    @document = WordToMarkdown::Document.new path, tmpdir
    @converter = WordToMarkdown::Converter.new @document
    converter.convert!
  end

  # source: https://github.com/ricn/libreconv/blob/master/lib/libreconv.rb#L48
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable? exe
      end
    end

    return nil
  end

  def self.soffice_path
    if RUBY_PLATFORM.include?("darwin")
      %w[~/Applications /Applications]
        .map  { |f| File.expand_path(File.join(f, "/LibreOffice.app/Contents/MacOS/soffice")) }
        .find { |f| File.file?(f) } || -> { raise RuntimeError.new("Coudln't find LibreOffice on your machine.") }.call
    else
      soffice_path ||= which("soffice")
      soffice_path ||= which("soffice.bin")
      soffice_path ||= "soffice"
    end
  end

  # Ideally this would be done via open3, but Travis CI can't seen to find soffice when we do
  def self.run_command(*args)
    `#{soffice_path} #{args.join(' ')}`
  end

  def self.soffice_version
    run_command('--version').strip.sub "LibreOffice ", ""
  end

  # Pretty print the class in console
  def inspect
    "<WordToMarkdown path=\"#{@document.path}\">"
  end

  def to_s
    document.to_s
  end
end
