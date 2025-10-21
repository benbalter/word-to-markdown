# frozen_string_literal: true

module CssParser
  def self.regex_possible_values(*values)
    Regexp.new("([\s]*^)?(#{values.join('|')})([\s]*$)?", 'i')
  end

  # :stopdoc:
  # Base types
  RE_NL = Regexp.new('(\n|\r\n|\r|\f)')
  RE_NON_ASCII = Regexp.new('([\x00-\xFF])', Regexp::IGNORECASE | Regexp::NOENCODING) # [^\0-\177]
  RE_UNICODE = Regexp.new('(\\\\[0-9a-f]{1,6}(\r\n|[ \n\r\t\f])*)', Regexp::IGNORECASE | Regexp::EXTENDED | Regexp::MULTILINE | Regexp::NOENCODING)
  RE_ESCAPE = Regexp.union(RE_UNICODE, '|(\\\\[^\n\r\f0-9a-f])')
  RE_IDENT = Regexp.new("[-]?([_a-z]|#{RE_NON_ASCII}|#{RE_ESCAPE})([_a-z0-9-]|#{RE_NON_ASCII}|#{RE_ESCAPE})*", Regexp::IGNORECASE | Regexp::NOENCODING)

  # General strings
  RE_STRING1 = /("(.[^\n\r\f"]*|\\#{RE_NL}|#{RE_ESCAPE})*")/.freeze
  RE_STRING2 = /('(.[^\n\r\f']*|\\#{RE_NL}|#{RE_ESCAPE})*')/.freeze
  RE_STRING = Regexp.union(RE_STRING1, RE_STRING2)

  RE_INHERIT = regex_possible_values 'inherit'

  RE_URI = /(url\(\s*(\s*#{RE_STRING}\s*)\s*\))|(url\(\s*([!#$%&*\-~]|#{RE_NON_ASCII}|#{RE_ESCAPE})*\s*)\)/ixm.freeze
  URI_RX = /url\(("([^"]*)"|'([^']*)'|([^)]*))\)/im.freeze
  URI_RX_OR_NONE = Regexp.union(URI_RX, /none/i)
  RE_GRADIENT = /[-a-z]*gradient\([-a-z0-9 .,#%()]*\)/im.freeze

  # Initial parsing
  RE_AT_IMPORT_RULE = /@import\s+(url\()?["']?(.[^'"\s]*)["']?\)?([\w\s,^\])]*)\)?;?/.freeze

  #--
  # RE_AT_MEDIA_RULE = Regexp.new('(\"(.[^\n\r\f\\"]*|\\\\' + RE_NL.to_s + '|' + RE_ESCAPE.to_s + ')*\")')

  # RE_AT_IMPORT_RULE = Regexp.new('@import[\s]*(' + RE_STRING.to_s + ')([\w\s\,]*)[;]?', Regexp::IGNORECASE) -- should handle url() even though it is not allowed
  #++
  IMPORTANT_IN_PROPERTY_RX = /\s*!important\b\s*/i.freeze

  RE_INSIDE_OUTSIDE = regex_possible_values 'inside', 'outside'
  RE_SCROLL_FIXED = regex_possible_values 'scroll', 'fixed'
  RE_REPEAT = regex_possible_values 'repeat(\-x|\-y)*|no\-repeat'
  RE_LIST_STYLE_TYPE = regex_possible_values(
    'disc', 'circle', 'square', 'decimal-leading-zero', 'decimal', 'lower-roman',
    'upper-roman', 'lower-greek', 'lower-alpha', 'lower-latin', 'upper-alpha',
    'upper-latin', 'hebrew', 'armenian', 'georgian', 'cjk-ideographic', 'hiragana',
    'hira-gana-iroha', 'katakana-iroha', 'katakana', 'none'
  )
  RE_IMAGE = Regexp.union(CssParser::URI_RX, CssParser::RE_GRADIENT, /none/i)

  STRIP_CSS_COMMENTS_RX = %r{/\*.*?\*/}m.freeze
  STRIP_HTML_COMMENTS_RX = /<!--|-->/m.freeze

  # Special units
  BOX_MODEL_UNITS_RX = /(auto|inherit|0|(-*([0-9]+|[0-9]*\.[0-9]+)(rem|vw|vh|vm|vmin|vmax|e[mx]+|px|[cm]+m|p[tc+]|in|%)))([\s;]|\Z)/imx.freeze
  RE_LENGTH_OR_PERCENTAGE = Regexp.new('([\-]*(([0-9]*\.[0-9]+)|[0-9]+)(e[mx]+|px|[cm]+m|p[tc+]|in|\%))', Regexp::IGNORECASE)
  RE_SINGLE_BACKGROUND_POSITION = /#{RE_LENGTH_OR_PERCENTAGE}|left|center|right|top|bottom/i.freeze
  RE_SINGLE_BACKGROUND_SIZE = /#{RE_LENGTH_OR_PERCENTAGE}|auto|cover|contain|initial|inherit/i.freeze
  RE_BACKGROUND_POSITION = /#{RE_SINGLE_BACKGROUND_POSITION}\s+#{RE_SINGLE_BACKGROUND_POSITION}|#{RE_SINGLE_BACKGROUND_POSITION}/.freeze
  RE_BACKGROUND_SIZE = %r{\s*/\s*(#{RE_SINGLE_BACKGROUND_SIZE}\s+#{RE_SINGLE_BACKGROUND_SIZE}|#{RE_SINGLE_BACKGROUND_SIZE})}.freeze
  FONT_UNITS_RX = /((x+-)*small|medium|larger*|auto|inherit|([0-9]+|[0-9]*\.[0-9]+)(e[mx]+|px|[cm]+m|p[tc+]|in|%)*)/i.freeze
  RE_BORDER_STYLE = /(\s*^)?(none|hidden|dotted|dashed|solid|double|dot-dash|dot-dot-dash|wave|groove|ridge|inset|outset)(\s*$)?/imx.freeze
  RE_BORDER_UNITS = Regexp.union(BOX_MODEL_UNITS_RX, /(thin|medium|thick)/i)

  # Functions like calc, var, clamp, etc.
  RE_FUNCTIONS = /
    (
      [a-z0-9-]+        # function name
    )
    (?>
      \(                # opening parenthesis
        (?:
          ([^()]+)
          |             # recursion via subexpression
          \g<0>
        )*
      \)                # closing parenthesis
    )
  /imx.freeze

  # Patterns for specificity calculations
  NON_ID_ATTRIBUTES_AND_PSEUDO_CLASSES_RX_NC = /
    (?:\.\w+)                     # classes
    |
    \[(?:\w+)                       # attributes
    |
    (?::(?:                          # pseudo classes
      link|visited|active
      |hover|focus
      |lang
      |target
      |enabled|disabled|checked|indeterminate
      |root
      |nth-child|nth-last-child|nth-of-type|nth-last-of-type
      |first-child|last-child|first-of-type|last-of-type
      |only-child|only-of-type
      |empty|contains
    ))
  /ix.freeze
  ELEMENTS_AND_PSEUDO_ELEMENTS_RX_NC = /
    (?:(?:^|[\s+>~]+)\w+       # elements
    |
    :{1,2}(?:                    # pseudo-elements
      after|before
      |first-letter|first-line
      |selection
    )
  )/ix.freeze

  # Colours
  NAMED_COLOURS = %w[
    aliceblue
    antiquewhite
    aqua
    aquamarine
    azure
    beige
    bisque
    black
    blanchedalmond
    blue
    blueviolet
    brown
    burlywood
    cadetblue
    chartreuse
    chocolate
    coral
    cornflowerblue
    cornsilk
    crimson
    cyan
    darkblue
    darkcyan
    darkgoldenrod
    darkgray
    darkgreen
    darkgrey
    darkkhaki
    darkmagenta
    darkolivegreen
    darkorange
    darkorchid
    darkred
    darksalmon
    darkseagreen
    darkslateblue
    darkslategray
    darkslategrey
    darkturquoise
    darkviolet
    deeppink
    deepskyblue
    dimgray
    dimgrey
    dodgerblue
    firebrick
    floralwhite
    forestgreen
    fuchsia
    gainsboro
    ghostwhite
    gold
    goldenrod
    gray
    green
    greenyellow
    grey
    honeydew
    hotpink
    indianred
    indigo
    ivory
    khaki
    lavender
    lavenderblush
    lawngreen
    lemonchiffon
    lightblue
    lightcoral
    lightcyan
    lightgoldenrodyellow
    lightgray
    lightgreen
    lightgrey
    lightpink
    lightsalmon
    lightseagreen
    lightskyblue
    lightslategray
    lightslategrey
    lightsteelblue
    lightyellow
    lime
    limegreen
    linen
    magenta
    maroon
    mediumaquamarine
    mediumblue
    mediumorchid
    mediumpurple
    mediumseagreen
    mediumslateblue
    mediumspringgreen
    mediumturquoise
    mediumvioletred
    midnightblue
    mintcream
    mistyrose
    moccasin
    navajowhite
    navy
    oldlace
    olive
    olivedrab
    orange
    orangered
    orchid
    palegoldenrod
    palegreen
    paleturquoise
    palevioletred
    papayawhip
    peachpuff
    peru
    pink
    plum
    powderblue
    purple
    red
    rosybrown
    royalblue
    saddlebrown
    salmon
    sandybrown
    seagreen
    seashell
    sienna
    silver
    skyblue
    slateblue
    slategray
    slategrey
    snow
    springgreen
    steelblue
    tan
    teal
    thistle
    tomato
    turquoise
    violet
    wheat
    white
    whitesmoke
    yellow
    yellowgreen

    transparent
    inherit
    currentColor
  ].freeze
  RE_COLOUR_NUMERIC = /\b(hsl|rgb)\s*\(-?\s*-?\d+(\.\d+)?%?\s*%?,-?\s*-?\d+(\.\d+)?%?\s*%?,-?\s*-?\d+(\.\d+)?%?\s*%?\)/i.freeze
  RE_COLOUR_NUMERIC_ALPHA = /\b(hsla|rgba)\s*\(-?\s*-?\d+(\.\d+)?%?\s*%?,-?\s*-?\d+(\.\d+)?%?\s*%?,-?\s*-?\d+(\.\d+)?%?\s*%?,-?\s*-?\d+(\.\d+)?%?\s*%?\)/i.freeze
  RE_COLOUR_HEX = /\s*#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b/.freeze
  RE_COLOUR_NAMED = /\s*\b(#{NAMED_COLOURS.join('|')})\b/i.freeze
  RE_COLOUR = Regexp.union(RE_COLOUR_NUMERIC, RE_COLOUR_NUMERIC_ALPHA, RE_COLOUR_HEX, RE_COLOUR_NAMED)
  # :startdoc:
end
