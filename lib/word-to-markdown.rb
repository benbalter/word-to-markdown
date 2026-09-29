# frozen_string_literal: true

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
require_relative 'word-to-markdown/input_format'
require_relative 'word-to-markdown/url_scrubber'
require_relative 'word-to-markdown/document'
require_relative 'word-to-markdown/converter'
require_relative 'nokogiri/xml/element'
require_relative 'cliver/dependency_ext'

class WordToMarkdown
  class TimeoutError < StandardError; end

  attr_reader :document, :converter

  # Options to be passed to Reverse Markdown
  REVERSE_MARKDOWN_OPTIONS = {
    unknown_tags: :bypass,
    github_flavored: true
  }.freeze

  # Default number of seconds to wait for LibreOffice to convert a document
  # before giving up. Can be overridden with the WORD_TO_MARKDOWN_TIMEOUT
  # environment variable, or by setting WordToMarkdown.timeout
  DEFAULT_TIMEOUT = 60

  # Minimum version of LibreOffice Required
  SOFFICE_VERSION_REQUIREMENT = '> 4.0'

  # Paths to look for LibreOffice, in order of preference
  PATHS = [
    '*', # Sub'd for ENV["PATH"]
    '~/Applications/LibreOffice.app/Contents/MacOS',
    '/Applications/LibreOffice.app/Contents/MacOS',
    '/Program Files/LibreOffice/program',
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
    attr_writer :timeout

    # @return [Numeric] seconds to wait for LibreOffice before giving up
    def timeout
      @timeout ||= Float(ENV.fetch('WORD_TO_MARKDOWN_TIMEOUT', DEFAULT_TIMEOUT))
    end

    # Run an soffice command
    #
    # @param args [string] one or more arguments to pass to the soffice command
    # @return [string] the command output
    def run_command(*args)
      raise 'LibreOffice already running' if soffice.open?

      output, status = capture_with_timeout(soffice.path, *args, timeout: timeout)
      logger.debug output
      raise "Command `#{soffice.path} #{args.join(' ')}` failed: #{output}" if status.exitstatus != 0

      output
    end

    # Run a command, capturing its combined output, and kill it (along with
    # any child processes) if it runs longer than the timeout
    #
    # @param command [Array<String>] the command and its arguments
    # @param timeout [Numeric] seconds to wait before killing the command
    # @return [Array(String, Process::Status)] the command output and status
    def capture_with_timeout(*command, timeout:)
      Open3.popen2e(*command, process_group_option) do |stdin, output, waiter|
        stdin.close
        reader = read_in_background(output)
        unless waiter.join(timeout)
          kill_process_group(waiter.pid)
          raise TimeoutError, "Command `#{command.join(' ')}` timed out after #{timeout} seconds"
        end

        [reader.value, waiter.value]
      end
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

    # Start commands in their own process group, so that on timeout any
    # processes they spawn (e.g., soffice.bin) are killed too
    def process_group_option
      Gem.win_platform? ? { new_pgroup: true } : { pgroup: true }
    end

    # Read a stream in a separate thread, so the command can't block on a full pipe
    #
    # @param io [IO] the stream to read
    # @return [Thread] a thread whose value is the stream's contents
    def read_in_background(io)
      Thread.new do
        io.read
      rescue IOError
        '' # The stream was closed after the command timed out
      end
    end

    # @param pid [Integer] the pid of a process group leader
    def kill_process_group(pid)
      Process.kill('KILL', Gem.win_platform? ? pid : -pid)
    rescue Errno::ESRCH
      nil
    end

    # Workaround for two upstream bugs:
    # 1. `soffice.exe --version` on windows opens a popup and returns a null string when manually closed
    # 2. Even if the second argument to Cliver is nil, Cliver thinks there's a requirement
    #    and will shell out to `soffice.exe --version`
    # In order to support Windows, don't pass *any* version requirement to Cliver
    def soffice_dependency_args
      args = [{ path: PATHS.join(File::PATH_SEPARATOR) }]
      if Gem.win_platform?
        args
      else
        args.unshift SOFFICE_VERSION_REQUIREMENT
      end
    end
  end
end
