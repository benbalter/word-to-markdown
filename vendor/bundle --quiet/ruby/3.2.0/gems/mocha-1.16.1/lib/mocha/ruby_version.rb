require 'mocha/deprecation'

module Mocha
  RUBY_V2_PLUS = Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2')

  unless RUBY_V2_PLUS
    Mocha::Deprecation.warning(
      'Versions of Ruby earlier than v2.0 will not be supported in future versions of Mocha.'
    )
  end
end
