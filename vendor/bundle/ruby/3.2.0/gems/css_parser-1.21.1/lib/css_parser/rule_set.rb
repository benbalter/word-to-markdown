# frozen_string_literal: true

require 'forwardable'

module CssParser
  class RuleSet
    # Patterns for specificity calculations
    RE_ELEMENTS_AND_PSEUDO_ELEMENTS = /((^|[\s+>]+)\w+|:(first-line|first-letter|before|after))/i.freeze
    RE_NON_ID_ATTRIBUTES_AND_PSEUDO_CLASSES = /(\.\w+)|(\[\w+)|(:(link|first-child|lang))/i.freeze

    BACKGROUND_PROPERTIES = ['background-color', 'background-image', 'background-repeat', 'background-position', 'background-size', 'background-attachment'].freeze
    LIST_STYLE_PROPERTIES = ['list-style-type', 'list-style-position', 'list-style-image'].freeze
    FONT_STYLE_PROPERTIES = ['font-style', 'font-variant', 'font-weight', 'font-size', 'line-height', 'font-family'].freeze
    FONT_WEIGHT_PROPERTIES = ['font-style', 'font-weight', 'font-variant'].freeze
    BORDER_STYLE_PROPERTIES = ['border-width', 'border-style', 'border-color'].freeze
    BORDER_PROPERTIES = ['border', 'border-left', 'border-right', 'border-top', 'border-bottom'].freeze
    DIMENSION_DIRECTIONS = [:top, :right, :bottom, :left].freeze

    NUMBER_OF_DIMENSIONS = 4

    DIMENSIONS = [
      ['margin', %w[margin-top margin-right margin-bottom margin-left]],
      ['padding', %w[padding-top padding-right padding-bottom padding-left]],
      ['border-color', %w[border-top-color border-right-color border-bottom-color border-left-color]],
      ['border-style', %w[border-top-style border-right-style border-bottom-style border-left-style]],
      ['border-width', %w[border-top-width border-right-width border-bottom-width border-left-width]]
    ].freeze

    WHITESPACE_REPLACEMENT = '___SPACE___'

    # Tokens for parse_declarations!
    COLON = ':'.freeze
    SEMICOLON = ';'.freeze
    LPAREN = '('.freeze
    RPAREN = ')'.freeze
    IMPORTANT = '!important'.freeze
    class Declarations
      class Value
        attr_reader :value
        attr_accessor :important

        def initialize(value, important: nil)
          self.value = value
          @important = important unless important.nil?
        end

        def value=(value)
          value = value.to_s.sub(/\s*;\s*\Z/, '')
          self.important = !value.slice!(CssParser::IMPORTANT_IN_PROPERTY_RX).nil?
          value.strip!
          raise ArgumentError, 'value is empty' if value.empty?

          @value = value.freeze
        end

        def to_s
          important ? "#{value} !important" : value
        end

        def ==(other)
          return false unless other.is_a?(self.class)

          value == other.value && important == other.important
        end
      end

      extend Forwardable

      def_delegators :declarations, :each, :each_value

      def initialize(declarations = {})
        self.declarations = {}
        declarations.each { |property, value| add_declaration!(property, value) }
      end

      # Add a CSS declaration
      # @param [#to_s] property that should be added
      # @param [Value, #to_s] value of the property
      #
      # @example
      #   declarations['color'] = 'blue'
      #
      #   puts declarations['color']
      #   => #<CssParser::RuleSet::Declarations::Value:0x000000000305c730 @important=false, @order=1, @value="blue">
      #
      # @example
      #   declarations['margin'] = '0px auto !important'
      #
      #   puts declarations['margin']
      #   => #<CssParser::RuleSet::Declarations::Value:0x00000000030c1838 @important=true, @order=2, @value="0px auto">
      #
      # If the property already exists its value will be over-written unless it was !important and the new value
      # is not !important.
      # If the value is empty - property will be deleted
      def []=(property, value)
        property = normalize_property(property)
        currently_important = declarations[property]&.important

        if value.is_a?(Value) && (!currently_important || value.important)
          declarations[property] = value
        elsif value.to_s.strip.empty?
          delete property
        else
          value = Value.new(value)
          declarations[property] = value if !currently_important || value.important
        end
      rescue ArgumentError => e
        raise e.exception, "#{property} #{e.message}"
      end
      alias add_declaration! []=

      def [](property)
        declarations[normalize_property(property)]
      end
      alias get_value []

      def key?(property)
        declarations.key?(normalize_property(property))
      end

      def size
        declarations.size
      end

      # Remove CSS declaration
      # @param [#to_s] property property to be removed
      #
      # @example
      #   declarations.delete('color')
      def delete(property)
        declarations.delete(normalize_property(property))
      end
      alias remove_declaration! delete

      # Replace CSS property with multiple declarations
      # @param [#to_s] property property name to be replaces
      # @param [Hash<String => [String, Value]>] replacements hash with properties to replace with
      #
      # @example
      #  declarations = Declarations.new('line-height' => '0.25px', 'font' => 'small-caps', 'font-size' => '12em')
      #  declarations.replace_declaration!('font', {'line-height' => '1px', 'font-variant' => 'small-caps', 'font-size' => '24px'})
      #  declarations
      #  => #<CssParser::RuleSet::Declarations:0x00000000029c3018
      #  @declarations=
      #  {"line-height"=>#<CssParser::RuleSet::Declarations::Value:0x00000000038ac458 @important=false, @value="1px">,
      #   "font-variant"=>#<CssParser::RuleSet::Declarations::Value:0x00000000039b3ec8 @important=false, @value="small-caps">,
      #   "font-size"=>#<CssParser::RuleSet::Declarations::Value:0x00000000029c2c80 @important=false, @value="12em">}>
      def replace_declaration!(property, replacements, preserve_importance: false)
        property = normalize_property(property)
        raise ArgumentError, "property #{property} does not exist" unless key?(property)

        replacement_declarations = self.class.new(replacements)

        if preserve_importance
          importance = get_value(property).important
          replacement_declarations.each_value { |value| value.important = importance }
        end

        replacement_keys = declarations.keys
        replacement_values = declarations.values
        property_index = replacement_keys.index(property)

        # We should preserve subsequent declarations of the same properties
        # and prior important ones if replacement one is not important
        replacements = replacement_declarations.each.with_object({}) do |(key, replacement), result|
          existing = declarations[key]

          # No existing -> set
          unless existing
            result[key] = replacement
            next
          end

          # Replacement more important than existing -> replace
          if replacement.important && !existing.important
            result[key] = replacement
            replaced_index = replacement_keys.index(key)
            replacement_keys.delete_at(replaced_index)
            replacement_values.delete_at(replaced_index)
            property_index -= 1 if replaced_index < property_index
            next
          end

          # Existing is more important than replacement -> keep
          next if !replacement.important && existing.important

          # Existing and replacement importance are the same,
          # value which is declared later wins
          result[key] = replacement if property_index > replacement_keys.index(key)
        end

        return if replacements.empty?

        replacement_keys.delete_at(property_index)
        replacement_keys.insert(property_index, *replacements.keys)

        replacement_values.delete_at(property_index)
        replacement_values.insert(property_index, *replacements.values)

        self.declarations = replacement_keys.zip(replacement_values).to_h
      end

      def to_s(options = {})
        str = declarations.reduce(+'') do |memo, (prop, value)|
          importance = options[:force_important] || value.important ? ' !important' : ''
          memo << "#{prop}: #{value.value}#{importance}; "
        end
        # TODO: Clean-up regexp doesn't seem to work
        str.gsub!(/^[\s^({)]+|[\n\r\f\t]*|\s+$/mx, '')
        str.strip!
        str
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        declarations == other.declarations && declarations.keys == other.declarations.keys
      end

    protected

      attr_reader :declarations

    private

      attr_writer :declarations

      def normalize_property(property)
        property = property.to_s.downcase
        property.strip!
        property
      end
    end

    extend Forwardable

    # optional field for storing source reference
    # File offset range
    attr_reader :offset
    # the local or remote location
    attr_accessor :filename

    # Array of selector strings.
    attr_reader :selectors

    # Integer with the specificity to use for this RuleSet.
    attr_accessor :specificity

    # @!method add_declaration!
    #   @see CssParser::RuleSet::Declarations#add_declaration!
    # @!method delete
    #   @see CssParser::RuleSet::Declarations#delete
    def_delegators :declarations, :add_declaration!, :delete
    alias []= add_declaration!
    alias remove_declaration! delete

    def initialize(*args, selectors: nil, block: nil, offset: nil, filename: nil, specificity: nil) # rubocop:disable Metrics/ParameterLists
      if args.any?
        if selectors || block || offset || filename || specificity
          raise ArgumentError, "don't mix positional and keyword arguments"
        end

        warn '[DEPRECATION] positional arguments are deprecated use keyword instead.', uplevel: 1

        case args.length
        when 2
          selectors, block = args
        when 3
          selectors, block, specificity = args
        when 4
          filename, offset, selectors, block = args
        when 5
          filename, offset, selectors, block, specificity = args
        else
          raise ArgumentError
        end
      end

      @selectors = []
      @specificity = specificity

      unless offset.nil? == filename.nil?
        raise ArgumentError, 'require both offset and filename or no offset and no filename'
      end

      @offset = offset
      @filename = filename

      parse_selectors!(selectors) if selectors
      parse_declarations!(block)
    end

    # Get the value of a property
    def get_value(property)
      return '' unless (value = declarations[property])

      "#{value};"
    end
    alias [] get_value

    # Iterate through selectors.
    #
    # Options
    # -  +force_important+ -- boolean
    #
    # ==== Example
    #   ruleset.each_selector do |sel, dec, spec|
    #     ...
    #   end
    def each_selector(options = {}) # :yields: selector, declarations, specificity
      decs = declarations.to_s(options)
      if @specificity
        @selectors.each { |sel| yield sel.strip, decs, @specificity }
      else
        @selectors.each { |sel| yield sel.strip, decs, CssParser.calculate_specificity(sel) }
      end
    end

    # Iterate through declarations.
    def each_declaration # :yields: property, value, is_important
      declarations.each do |property_name, value|
        yield property_name, value.value, value.important
      end
    end

    # Return all declarations as a string.
    def declarations_to_s(options = {})
      declarations.to_s(options)
    end

    # Return the CSS rule set as a string.
    def to_s
      "#{@selectors.join(',')} { #{declarations} }"
    end

    # Split shorthand declarations (e.g. +margin+ or +font+) into their constituent parts.
    def expand_shorthand!
      # border must be expanded before dimensions
      expand_border_shorthand!
      expand_dimensions_shorthand!
      expand_font_shorthand!
      expand_background_shorthand!
      expand_list_style_shorthand!
    end

    # Convert shorthand background declarations (e.g. <tt>background: url("chess.png") gray 50% repeat fixed;</tt>)
    # into their constituent parts.
    #
    # See http://www.w3.org/TR/CSS21/colors.html#propdef-background
    def expand_background_shorthand! # :nodoc:
      return unless (declaration = declarations['background'])

      value = declaration.value.dup

      replacement =
        if value.match(CssParser::RE_INHERIT)
          BACKGROUND_PROPERTIES.to_h { |key| [key, 'inherit'] }
        else
          {
            'background-image' => value.slice!(CssParser::RE_IMAGE),
            'background-attachment' => value.slice!(CssParser::RE_SCROLL_FIXED),
            'background-repeat' => value.slice!(CssParser::RE_REPEAT),
            'background-color' => value.slice!(CssParser::RE_COLOUR),
            'background-size' => extract_background_size_from(value),
            'background-position' => value.slice!(CssParser::RE_BACKGROUND_POSITION)
          }
        end

      declarations.replace_declaration!('background', replacement, preserve_importance: true)
    end

    def extract_background_size_from(value)
      size = value.slice!(CssParser::RE_BACKGROUND_SIZE)

      size.sub(%r{^\s*/\s*}, '') if size
    end

    # Split shorthand border declarations (e.g. <tt>border: 1px red;</tt>)
    # Additional splitting happens in expand_dimensions_shorthand!
    def expand_border_shorthand! # :nodoc:
      BORDER_PROPERTIES.each do |k|
        next unless (declaration = declarations[k])

        value = declaration.value.dup

        replacement = {
          "#{k}-width" => value.slice!(CssParser::RE_BORDER_UNITS),
          "#{k}-color" => value.slice!(CssParser::RE_COLOUR),
          "#{k}-style" => value.slice!(CssParser::RE_BORDER_STYLE)
        }

        declarations.replace_declaration!(k, replacement, preserve_importance: true)
      end
    end

    # Split shorthand dimensional declarations (e.g. <tt>margin: 0px auto;</tt>)
    # into their constituent parts.  Handles margin, padding, border-color, border-style and border-width.
    def expand_dimensions_shorthand! # :nodoc:
      DIMENSIONS.each do |property, (top, right, bottom, left)|
        next unless (declaration = declarations[property])

        value = declaration.value.dup

        # RGB and HSL values in borders are the only units that can have spaces (within params).
        # We cheat a bit here by stripping spaces after commas in RGB and HSL values so that we
        # can split easily on spaces.
        #
        # TODO: rgba, hsl, hsla
        value.gsub!(RE_COLOUR) { |c| c.gsub(/(\s*,\s*)/, ',') }

        matches = split_value_preserving_function_whitespace(value)

        case matches.length
        when 1
          values = matches.to_a * 4
        when 2
          values = matches.to_a * 2
        when 3
          values = matches.to_a
          values << matches[1] # left = right
        when 4
          values = matches.to_a
        else
          raise ArgumentError, "Cannot parse #{value}"
        end

        replacement = [top, right, bottom, left].zip(values).to_h

        declarations.replace_declaration!(property, replacement, preserve_importance: true)
      end
    end

    # Convert shorthand font declarations (e.g. <tt>font: 300 italic 11px/14px verdana, helvetica, sans-serif;</tt>)
    # into their constituent parts.
    def expand_font_shorthand! # :nodoc:
      return unless (declaration = declarations['font'])

      # reset properties to 'normal' per http://www.w3.org/TR/CSS21/fonts.html#font-shorthand
      font_props = {
        'font-style' => 'normal',
        'font-variant' => 'normal',
        'font-weight' => 'normal',
        'font-size' => 'normal',
        'line-height' => 'normal'
      }

      value = declaration.value.dup
      value.gsub!(%r{/\s+}, '/') # handle spaces between font size and height shorthand (e.g. 14px/ 16px)

      in_fonts = false

      matches = value.scan(/"(?:.*[^"])"|'(?:.*[^'])'|(?:\w[^ ,]+)/)
      matches.each do |m|
        m.strip!
        m.gsub!(/;$/, '')

        if in_fonts
          if font_props.key?('font-family')
            font_props['font-family'] += ", #{m}"
          else
            font_props['font-family'] = m
          end
        elsif /normal|inherit/i.match?(m)
          FONT_WEIGHT_PROPERTIES.each do |font_prop|
            font_props[font_prop] ||= m
          end
        elsif /italic|oblique/i.match?(m)
          font_props['font-style'] = m
        elsif /small-caps/i.match?(m)
          font_props['font-variant'] = m
        elsif /[1-9]00$|bold|bolder|lighter/i.match?(m)
          font_props['font-weight'] = m
        elsif CssParser::FONT_UNITS_RX.match?(m)
          if m.include?('/')
            font_props['font-size'], font_props['line-height'] = m.split('/', 2)
          else
            font_props['font-size'] = m
          end
          in_fonts = true
        end
      end

      declarations.replace_declaration!('font', font_props, preserve_importance: true)
    end

    # Convert shorthand list-style declarations (e.g. <tt>list-style: lower-alpha outside;</tt>)
    # into their constituent parts.
    #
    # See http://www.w3.org/TR/CSS21/generate.html#lists
    def expand_list_style_shorthand! # :nodoc:
      return unless (declaration = declarations['list-style'])

      value = declaration.value.dup

      replacement =
        if CssParser::RE_INHERIT.match?(value)
          LIST_STYLE_PROPERTIES.to_h { |key| [key, 'inherit'] }
        else
          {
            'list-style-type' => value.slice!(CssParser::RE_LIST_STYLE_TYPE),
            'list-style-position' => value.slice!(CssParser::RE_INSIDE_OUTSIDE),
            'list-style-image' => value.slice!(CssParser::URI_RX_OR_NONE)
          }
        end

      declarations.replace_declaration!('list-style', replacement, preserve_importance: true)
    end

    # Create shorthand declarations (e.g. +margin+ or +font+) whenever possible.
    def create_shorthand!
      create_background_shorthand!
      create_dimensions_shorthand!
      # border must be shortened after dimensions
      create_border_shorthand!
      create_font_shorthand!
      create_list_style_shorthand!
    end

    # Combine several properties into a shorthand one
    def create_shorthand_properties!(properties, shorthand_property) # :nodoc:
      values = []
      properties_to_delete = []
      properties.each do |property|
        next unless (declaration = declarations[property])
        next if declaration.important

        values << declaration.value
        properties_to_delete << property
      end

      return if values.length <= 1

      properties_to_delete.each do |property|
        declarations.delete(property)
      end

      declarations[shorthand_property] = values.join(' ')
    end

    # Looks for long format CSS background properties (e.g. <tt>background-color</tt>) and
    # converts them into a shorthand CSS <tt>background</tt> property.
    #
    # Leaves properties declared !important alone.
    def create_background_shorthand! # :nodoc:
      # When we have a background-size property we must separate it and distinguish it from
      # background-position by preceding it with a backslash. In this case we also need to
      # have a background-position property, so we set it if it's missing.
      # http://www.w3schools.com/cssref/css3_pr_background.asp
      if (declaration = declarations['background-size']) && !declaration.important
        declarations['background-position'] ||= '0% 0%'
        declaration.value = "/ #{declaration.value}"
      end

      create_shorthand_properties! BACKGROUND_PROPERTIES, 'background'
    end

    # Combine border-color, border-style and border-width into border
    # Should be run after create_dimensions_shorthand!
    #
    # TODO: this is extremely similar to create_background_shorthand! and should be combined
    def create_border_shorthand! # :nodoc:
      values = BORDER_STYLE_PROPERTIES.filter_map do |property|
        next unless (declaration = declarations[property])
        next if declaration.important
        # can't merge if any value contains a space (i.e. has multiple values)
        # we temporarily remove any spaces after commas for the check (inside rgba, etc...)
        next if /\s/.match?(declaration.value.gsub(/,\s/, ',').strip)

        declaration.value
      end

      return if values.size != BORDER_STYLE_PROPERTIES.size

      BORDER_STYLE_PROPERTIES.each do |property|
        declarations.delete(property)
      end

      declarations['border'] = values.join(' ')
    end

    # Looks for long format CSS dimensional properties (margin, padding, border-color, border-style and border-width)
    # and converts them into shorthand CSS properties.
    def create_dimensions_shorthand! # :nodoc:
      return if declarations.size < NUMBER_OF_DIMENSIONS

      DIMENSIONS.each do |property, dimensions|
        values = DIMENSION_DIRECTIONS.each_with_index.with_object({}) do |(side, index), result|
          next unless (declaration = declarations[dimensions[index]])

          result[side] = declaration.value
        end

        # All four dimensions must be present
        next if values.size != dimensions.size

        new_value = values.values_at(*compute_dimensions_shorthand(values)).join(' ').strip
        declarations[property] = new_value unless new_value.empty?

        # Delete the longhand values
        dimensions.each { |d| declarations.delete(d) }
      end
    end

    # Looks for long format CSS font properties (e.g. <tt>font-weight</tt>) and
    # tries to convert them into a shorthand CSS <tt>font</tt> property.  All
    # font properties must be present in order to create a shorthand declaration.
    def create_font_shorthand! # :nodoc:
      return unless FONT_STYLE_PROPERTIES.all? { |prop| declarations.key?(prop) }

      new_value = +''
      ['font-style', 'font-variant', 'font-weight'].each do |property|
        unless declarations[property].value == 'normal'
          new_value << declarations[property].value << ' '
        end
      end

      new_value << declarations['font-size'].value

      unless declarations['line-height'].value == 'normal'
        new_value << '/' << declarations['line-height'].value
      end

      new_value << ' ' << declarations['font-family'].value

      declarations['font'] = new_value.gsub(/\s+/, ' ')

      FONT_STYLE_PROPERTIES.each { |prop| declarations.delete(prop) }
    end

    # Looks for long format CSS list-style properties (e.g. <tt>list-style-type</tt>) and
    # converts them into a shorthand CSS <tt>list-style</tt> property.
    #
    # Leaves properties declared !important alone.
    def create_list_style_shorthand! # :nodoc:
      create_shorthand_properties! LIST_STYLE_PROPERTIES, 'list-style'
    end

  private

    attr_accessor :declarations

    def compute_dimensions_shorthand(values)
      # All four sides are equal, returning single value
      return [:top] if values.values.uniq.count == 1

      # `/* top | right | bottom | left */`
      return DIMENSION_DIRECTIONS if values[:left] != values[:right]

      # Vertical are the same & horizontal are the same, `/* vertical | horizontal */`
      return [:top, :left] if values[:top] == values[:bottom]

      [:top, :left, :bottom]
    end

    def parse_declarations!(block) # :nodoc:
      self.declarations = Declarations.new

      return unless block

      continuation = nil
      block.split(SEMICOLON) do |decs|
        decs = (continuation ? "#{continuation};#{decs}" : decs)
        if unmatched_open_parenthesis?(decs)
          # Semicolon happened within parenthesis, so it is a part of the value
          # the rest of the value is in the next segment
          continuation = decs
          next
        end

        next unless (colon = decs.index(COLON))

        property = decs[0, colon]
        value = decs[(colon + 1)..]
        property.strip!
        value.strip!
        next if property.empty? || value.empty? || value.casecmp?(IMPORTANT)

        add_declaration!(property, value)
        continuation = nil
      end
    end

    def unmatched_open_parenthesis?(declarations)
      (lparen_index = declarations.index(LPAREN)) && !declarations.index(RPAREN, lparen_index)
    end

    #--
    # TODO: way too simplistic
    #++
    def parse_selectors!(selectors) # :nodoc:
      @selectors = selectors.split(',').map do |s|
        s.gsub!(/\s+/, ' ')
        s.strip!
        s
      end
    end

    def split_value_preserving_function_whitespace(value)
      split_value = value.gsub(RE_FUNCTIONS) do |c|
        c.gsub!(/\s+/, WHITESPACE_REPLACEMENT)
        c
      end

      matches = split_value.strip.split(/\s+/)

      matches.each do |c|
        c.gsub!(WHITESPACE_REPLACEMENT, ' ')
      end
    end
  end
end
