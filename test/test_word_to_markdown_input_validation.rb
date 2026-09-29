# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownInputValidation < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def write_file(name, content)
    path = File.join(@dir, name)
    File.binwrite(path, content)
    path
  end

  should 'reject an HTML file with a .docx extension' do
    WordToMarkdown.expects(:run_command).never

    assert_raises(WordToMarkdown::Document::UnsupportedFormatError) { WordToMarkdown.new fixture_path('html') }
  end

  should 'reject a ZIP file that is not a Word document' do
    assert_raises(WordToMarkdown::Document::UnsupportedFormatError) { WordToMarkdown::Document.new fixture_path('zip') }
  end

  should 'reject a truncated ZIP file' do
    path = write_file('document.docx', "PK\x03\x04word/document.xml")

    assert_raises(WordToMarkdown::Document::UnsupportedFormatError) { WordToMarkdown::Document.new path }
  end

  should 'reject an empty file' do
    path = write_file('document.docx', '')

    assert_raises(WordToMarkdown::Document::UnsupportedFormatError) { WordToMarkdown::Document.new path }
  end

  should 'detect .docx files' do
    assert_equal 'MS Word 2007 XML', WordToMarkdown::Document.new(fixture_path('em')).import_filter
  end

  should 'detect .doc files' do
    assert_equal 'MS Word 97', WordToMarkdown::Document.new(fixture_path('em').sub(/\.docx\z/, '.doc')).import_filter
  end

  should 'pass the import filter to LibreOffice' do
    document = WordToMarkdown::Document.new fixture_path('em')
    WordToMarkdown.expects(:run_command).with('--headless', '--infilter=MS Word 2007 XML', '--convert-to', anything, document.path, '--outdir', document.tmpdir)

    assert_raises(WordToMarkdown::Document::ConversionError) { document.send(:raw_html) }
  end

  should 'not let LibreOffice import other formats as Word documents' do
    WordToMarkdown::InputFormat.stubs(:filter_for).returns('MS Word 2007 XML')

    assert_raises(RuntimeError) { WordToMarkdown.new fixture_path('html') }
  end

  should 'convert .doc files' do
    assert_equal 'This word is _italic_.', WordToMarkdown.new(fixture_path('em').sub(/\.docx\z/, '.doc')).to_s
  end

  should 'kill commands that exceed the timeout' do
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    error = assert_raises(WordToMarkdown::TimeoutError) do
      WordToMarkdown.capture_with_timeout(RbConfig.ruby, '-e', 'sleep 30', timeout: 0.5)
    end

    assert_includes error.message, 'timed out'
    assert_operator Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, :<, 10
  end

  should 'kill child processes of commands that exceed the timeout' do
    skip 'Process groups are not signalled on Windows' if Gem.win_platform?

    pid_file = File.join(@dir, 'child.pid')
    script = "File.write(#{pid_file.inspect}, spawn(#{RbConfig.ruby.inspect}, '-e', 'sleep 30').to_s); sleep 30"
    assert_raises(WordToMarkdown::TimeoutError) do
      WordToMarkdown.capture_with_timeout(RbConfig.ruby, '-e', script, timeout: 1)
    end
    child = Integer(File.read(pid_file))
    sleep 0.2

    assert_raises(Errno::ESRCH) { Process.kill(0, child) }
  end

  should 'return the output and status of commands within the timeout' do
    output, status = WordToMarkdown.capture_with_timeout(RbConfig.ruby, '-e', 'print "ok"', timeout: 10)

    assert_equal 'ok', output
    assert_predicate status, :success?
  end
end
