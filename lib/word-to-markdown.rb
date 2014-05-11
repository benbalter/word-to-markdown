require 'reverse_markdown'
require 'descriptive_statistics'
require 'premailer'
require 'nokogiri'
require 'nokogiri-styles'
require 'open3'
require 'dotenv'
require 'tmpdir'
require_relative 'word-to-markdown/document'
require_relative 'word-to-markdown/converter'
require_relative 'nokogiri/xml/element'

Dotenv.load

class WordToMarkdown

  attr_reader :document, :converter

  # Create a new WordToMarkdown object
  #
  # input - a HTML string or path to an HTML file
  #
  # Returns the WordToMarkdown object
  def initialize(path)
    @document = WordToMarkdown::Document.new path
    @converter = WordToMarkdown::Converter.new @document
    converter.convert!
  end

  def self.soffice_in_path
    ENV['PATH'].split(':').any? {|path| File.exists? "#{path}/soffice" }
  end

  def self.soffice_path
    if ENV['SOFFICE_PATH']
      ENV['SOFFICE_PATH']
    elsif soffice_in_path
      "soffice"
    end
  end

  def self.run_command(*args)
    raise "Must define SOFFICE_PATH." unless soffice_path
    output, status = Open3.capture2e soffice_path, *args
    raise "soffice command failed: #{output}" if status != 0
    output
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
