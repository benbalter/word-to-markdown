# frozen_string_literal: true

require 'descriptive_statistics/safe'
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

  # Options to be passed to Reverse Markdown
  REVERSE_MARKDOWN_OPTIONS = {
    unknown_tags: :bypass,
    github_flavored: true
  }.freeze

  # Minimum version of LibreOffice Required
  SOFFICE_VERSION_REQUIREMENT = '> 4.0'

  # Paths to look for LibreOffice, in order of preference
  PATHS = [
    '*', # Sub'd for ENV["PATH"]
    '~/Applications/LibreOffice.app/Contents/MacOS',
    '/Applications/LibreOffice.app/Contents/MacOS',
    '/Program Files/LibreOffice 5/program',
    '/Program Files (x86)/LibreOffice 4/program'
  ].freeze

  # Create a new WordToMarkdown object
  #
  # @param path [string] Path to the Word document
  # @param tmpdir [string] Path to a working directory to use
  # @return [WordToMarkdown] WordToMarkdown object with the converted document
  def initialize(path, tmpdir = nil)
    @document = WordToMarkdown::Document.new path, tmpdir
    @converter = WordToMarkdown::Converter.new @document
    converter.convert!
  end

  # Helper method to return the document body, as markdown
  # @return [string] the document body, as markdown
  def to_s
    document.to_s
  end

  class << self
    # Run an soffice command
    #
    # @param args [string] one or more arguments to pass to the sofice command
    # @return [string] the command output
    def run_command(*args)
      raise 'LibreOffice already running' if soffice.open?

      output, status = Open3.capture2e(soffice.path, *args)
      logger.debug output
      raise "Command `#{soffice.path} #{args.join(' ')}` failed: #{output}" if status.exitstatus != 0

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
    # @return Cliver::Dependency instance
    def soffice
      @soffice ||= Cliver::Dependency.new('soffice', *soffice_dependency_args)
    end

    # @return Logger instance
    def logger
      @logger ||= begin
        logger = Logger.new($stdout)
        logger.level = Logger::ERROR unless ENV['DEBUG']
        logger
      end
    end

    private

    # Workaround for two upstream bugs:
    # 1. `soffice.exe --version` on windows opens a popup and retuns a null string when manually closed
    # 2. Even if the second argument to Cliver is nil, Cliver thinks there's a requirement
    #    and will shell out to `soffice.exe --version`
    # In order to support Windows, don't pass *any* version requirement to Cliver
    def soffice_dependency_args
      args = [path: PATHS.join(File::PATH_SEPARATOR)]
      if Gem.win_platform?
        args
      else
        args.unshift SOFFICE_VERSION_REQUIREMENT
      end
    end
  end
end
