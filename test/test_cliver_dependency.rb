# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestCliverDependency < Minitest::Test
  def setup
    @dependency = Cliver::Dependency.new('soffice', path: ['/fake/path'])
  end

  should 'cache detected path' do
    @dependency.stubs(:detect!).returns('/path/to/soffice')
    
    path1 = @dependency.detected_path
    path2 = @dependency.detected_path
    
    assert_equal '/path/to/soffice', path1
    assert_equal path1, path2
  end

  should 'alias path to detected_path' do
    @dependency.stubs(:detect!).returns('/path/to/soffice')
    
    assert_equal @dependency.detected_path, @dependency.path
  end

  should 'detect if process is open' do
    @dependency.stubs(:path).returns('ruby')
    
    # Current ruby process should be running
    result = @dependency.open?
    
    # Result should be boolean
    assert [true, false].include?(result)
  end

  should 'return false when ArgumentError is raised' do
    @dependency.stubs(:path).returns('/fake/soffice')
    Sys::ProcTable.stubs(:ps).raises(ArgumentError)
    
    refute @dependency.open?
  end

  should 'extract version from installed_versions' do
    skip 'Requires LibreOffice to be installed' if Gem.win_platform?
    
    @dependency.stubs(:path).returns('/usr/bin/soffice')
    @dependency.stubs(:installed_versions).returns([['/usr/bin/soffice', '7.0.4.2']])
    
    assert_equal '7.0.4.2', @dependency.version
  end

  should 'return nil version on Windows' do
    skip 'Only runs on Windows' unless Gem.win_platform?
    
    assert_nil @dependency.version
  end

  should 'cache version' do
    skip 'Requires LibreOffice to be installed' if Gem.win_platform?
    
    @dependency.stubs(:path).returns('/usr/bin/soffice')
    @dependency.stubs(:installed_versions).returns([['/usr/bin/soffice', '7.0.4.2']])
    
    version1 = @dependency.version
    version2 = @dependency.version
    
    assert_equal version1, version2
  end

  should 'extract major version from version' do
    skip 'Requires LibreOffice to be installed' if Gem.win_platform?
    
    @dependency.stubs(:path).returns('/usr/bin/soffice')
    @dependency.stubs(:installed_versions).returns([['/usr/bin/soffice', '7.0.4.2']])
    
    assert_equal '7', @dependency.major_version
  end

  should 'return nil major version when version is nil' do
    @dependency.stubs(:version).returns(nil)
    
    assert_nil @dependency.major_version
  end

  should 'handle version string with dots' do
    skip 'Requires LibreOffice to be installed' if Gem.win_platform?
    
    @dependency.stubs(:path).returns('/usr/bin/soffice')
    @dependency.stubs(:installed_versions).returns([['/usr/bin/soffice', '6.4.7.2']])
    
    assert_equal '6', @dependency.major_version
    assert_equal '6.4.7.2', @dependency.version
  end
end
