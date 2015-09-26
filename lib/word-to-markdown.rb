require 'descriptive_statistics'
require 'reverse_markdown'
require 'nokogiri-styles'
require 'premailer'
require 'rbconfig'
require 'nokogiri'
require 'logger'
require 'tmpdir'
require 'cliver'
require 'open3'

require_relative 'word-to-markdown/version'
require_relative 'word-to-markdown/document'
require_relative 'word-to-markdown/converter'
require_relative 'nokogiri/xml/element'
require_relative 'cliver/dependency_ext'

class WordToMarkdown

  attr_reader :document, :converter

  REVERSE_MARKDOWN_OPTIONS = {
    unknown_tags: :bypass,
    github_flavored: true
  }

  SOFFICE_VERSION_REQUIREMENT = '> 4.0'

  PATHS = [
    "~/Applications/LibreOffice.app/Contents/MacOS",
    "/Applications/LibreOffice.app/Contents/MacOS",
    "/C/Program Files (x86)/LibreOffice 4/program"
  ]

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

  def self.run_command(*args)
    raise "LibreOffice already running" if soffice.open?

    output, status = Open3.capture2e(soffice.path, *args)
    logger.debug output
    raise "Command `#{soffice_path} #{args.join(" ")}` failed: #{output}" if status.exitstatus != 0
    output
  end

  # Returns a Cliver::Dependency object representing our soffice dependency
  #
  # Attempts to resolve by looking at PATH followed by paths in the PATHS constant
  #
  # Methods used internally:
  #   path    - returns the resolved path. Raises an error if not satisfied
  #   version - returns the resolved version
  #   open    - is the dependency currently open/running?
  def self.soffice
    @@soffice_dependency ||= Cliver::Dependency.new(
      "soffice", SOFFICE_VERSION_REQUIREMENT,
      :path => "*:" + PATHS.join(":")
    )
  end

  def self.logger
    @@logger ||= begin
      logger = Logger.new(STDOUT)
      logger.level = Logger::ERROR unless ENV["DEBUG"]
      logger
    end
  end

  # Pretty print the class in console
  def inspect
    "<WordToMarkdown path=\"#{@document.path}\">"
  end

  def to_s
    document.to_s
  end
end
