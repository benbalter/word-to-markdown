# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownClass < Minitest::Test
  should 'have reverse markdown options' do
    options = WordToMarkdown::REVERSE_MARKDOWN_OPTIONS
    
    assert_equal :bypass, options[:unknown_tags]
    assert_equal true, options[:github_flavored]
  end

  should 'have soffice version requirement' do
    assert_equal '> 4.0', WordToMarkdown::SOFFICE_VERSION_REQUIREMENT
  end

  should 'have paths constant' do
    paths = WordToMarkdown::PATHS
    
    assert_instance_of Array, paths
    assert_includes paths, '*'
    assert_includes paths, '~/Applications/LibreOffice.app/Contents/MacOS'
  end

  should 'initialize with path' do
    doc = WordToMarkdown.new fixture_path('em')
    
    assert_instance_of WordToMarkdown, doc
    assert_instance_of WordToMarkdown::Document, doc.document
    assert_instance_of WordToMarkdown::Converter, doc.converter
  end

  should 'initialize with path and tmpdir' do
    tmpdir = Dir.mktmpdir
    doc = WordToMarkdown.new fixture_path('em'), tmpdir
    
    assert_equal tmpdir, doc.document.tmpdir
    FileUtils.rm_rf(tmpdir)
  end

  should 'return markdown via to_s' do
    doc = WordToMarkdown.new fixture_path('em')
    result = doc.to_s
    
    assert_instance_of String, result
    assert_includes result, '_italic_'
  end

  should 'have a logger' do
    logger = WordToMarkdown.logger
    
    assert_instance_of Logger, logger
  end

  should 'set logger level to ERROR by default' do
    # Save original ENV
    original_debug = ENV['DEBUG']
    ENV.delete('DEBUG')
    
    # Reset cached logger
    WordToMarkdown.instance_variable_set(:@logger, nil)
    
    logger = WordToMarkdown.logger
    assert_equal Logger::ERROR, logger.level
    
    # Restore original ENV
    ENV['DEBUG'] = original_debug if original_debug
  end

  should 'set logger level to DEBUG when ENV DEBUG is set' do
    # Save original ENV
    original_debug = ENV['DEBUG']
    ENV['DEBUG'] = 'true'
    
    # Reset cached logger
    WordToMarkdown.instance_variable_set(:@logger, nil)
    
    logger = WordToMarkdown.logger
    assert_equal Logger::DEBUG, logger.level
    
    # Restore original ENV
    ENV.delete('DEBUG')
    ENV['DEBUG'] = original_debug if original_debug
  end

  should 'have soffice dependency' do
    # Reset cached soffice to get a fresh instance for this test
    WordToMarkdown.instance_variable_set(:@soffice, nil)
    
    soffice = WordToMarkdown.soffice
    
    assert_instance_of Cliver::Dependency, soffice
  end

  should 'cache soffice dependency' do
    # Reset cached soffice to get a fresh instance for this test
    WordToMarkdown.instance_variable_set(:@soffice, nil)
    
    soffice1 = WordToMarkdown.soffice
    soffice2 = WordToMarkdown.soffice
    
    assert_equal soffice1.object_id, soffice2.object_id
  end

  unless Gem.win_platform?
    should 'include version requirement on non-Windows' do
      WordToMarkdown.instance_variable_set(:@soffice, nil)
      
      # Mock Cliver::Dependency to check arguments
      Cliver::Dependency.expects(:new).with do |name, *args|
        name == 'soffice' && args.include?(WordToMarkdown::SOFFICE_VERSION_REQUIREMENT)
      end.returns(stub(detect!: '/fake/path'))
      
      WordToMarkdown.soffice
    end
  end

  if Gem.win_platform?
    should 'exclude version requirement on Windows' do
      WordToMarkdown.instance_variable_set(:@soffice, nil)
      
      # Mock Cliver::Dependency to check arguments
      Cliver::Dependency.expects(:new).with do |name, *args|
        name == 'soffice' && !args.include?(WordToMarkdown::SOFFICE_VERSION_REQUIREMENT)
      end.returns(stub(detect!: '/fake/path'))
      
      WordToMarkdown.soffice
    end
  end
end
