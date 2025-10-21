# Changelog

## 2.0.0 (2020-06-13)

### Backward-incompatible changes

* Drop support for RSpec 2 matchers. Matchers passed to `should` must conform
  to RSpec 3's API (`failure_message` and `failure_message_when_negated`).
* Drop support for older versions of Rails. Rails 4.x-6.x are the
  only versions supported now.
* Drop support for older versions of Ruby. Ruby 2.4.x-2.7.x are the only
  versions supported now.

### Bug fixes

* Fix how test names are generated so that when including the name of the
  outermost test class, "Test" is not removed from the class name if it does not
  fall at the end.
* Remove warning from Ruby about `context` not being used when using the gem
  with warnings enabled.
* Fix macro autoloading code. Files intended to hold custom macros which are
  located in either `test/shoulda_macros`, `vendor/gems/*/shoulda_macros`, or
  `vendor/plugins/*/shoulda_macros` are now loaded and mixed into your test
  framework's automatically.
* Restore compatibility with Shoulda Matchers, starting from 3.0.
* Fix some compatibility issues with Minitest 5.
* Fix running tests within a Rails < 5.2 environment so that when tests fail, an
  error is not produced claiming that Minitest::Result cannot find a test
  method.
