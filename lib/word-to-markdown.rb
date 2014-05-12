require 'reverse_markdown'
require 'descriptive_statistics'
require 'premailer'
require 'nokogiri'
require 'nokogiri-styles'
require 'open3'
require 'tmpdir'
require_relative 'word-to-markdown/document'
require_relative 'word-to-markdown/converter'
require_relative 'nokogiri/xml/element'

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
    if false && RUBY_PLATFORM.include?("darwin")
      "/Applications/LibreOffice.app/Contents/MacOS/soffice"
    else
      soffice_path ||= which("soffice")
      soffice_path ||= which("soffice.bin")
      soffice_path ||= "soffice"
    end
  end

  def self.run_command(*args)
    puts "soffice binary: #{soffice_path}"
    output, status = Open3.capture2e {'PATH' => ".:#{ENV['PATH']}"}, soffice_path, *args
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
