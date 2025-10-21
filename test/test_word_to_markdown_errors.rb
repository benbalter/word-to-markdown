# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownErrors < Minitest::Test
  should 'raise NotFoundError for missing file' do
    assert_raises(WordToMarkdown::Document::NotFoundError) do
      WordToMarkdown::Document.new '/path/to/nonexistent.docx'
    end
  end

  should 'include filename in NotFoundError message' do
    error = assert_raises(WordToMarkdown::Document::NotFoundError) do
      WordToMarkdown::Document.new '/path/to/missing.docx'
    end
    
    assert_includes error.message, 'missing.docx'
  end

  should 'raise error when LibreOffice is already running' do
    WordToMarkdown.soffice.stubs(:open?).returns(true)
    
    assert_raises(RuntimeError) do
      WordToMarkdown.run_command '--version'
    end
  end

  should 'raise error on failed command' do
    skip 'Requires LibreOffice to be installed'
    WordToMarkdown.soffice.stubs(:open?).returns(false)
    
    # This should fail with an invalid command
    assert_raises(RuntimeError) do
      WordToMarkdown.run_command '--invalid-option-xyz'
    end
  end
end
