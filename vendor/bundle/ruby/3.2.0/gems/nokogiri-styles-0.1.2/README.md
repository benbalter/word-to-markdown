# nokogiri-styles

NokgiriStyles lets you decompose inline CSS styling (the style attribute) in
HTML elements so you don’t have to bother with regexes and such.

## Usage

    require 'nokogiri'
    require 'nokogiri-styles'

    # ...

    # Get styles
    node['style']         # => 'width: 400px; color: blue'
    node.styles['width']  # => '400px'
    node.styles['color']  # => 'blue'

    # Update styles
    style = node.styles
    style['width']  = '500px'
    style['height'] = '300px'
    style['color']  = nil
    node.styles = style
    node['style']         # => 'width: 500xp; height: 300px'

    # Modify classes
    node['class']         # => 'foo bar'
    node.classes          # => ['foo', 'bar']
    node.classes = ['foo']
    node['class']         # => 'foo'

Note that the `style` attribute is only updated when assigning `.styles`,
simply doing `node.styles['color'] = 'red'` does not work. Patches welcome.

## Installation

Add this line to your application's Gemfile:

    gem 'nokogiri-styles'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nokogiri-styles

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
