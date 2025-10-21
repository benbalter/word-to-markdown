require 'nokogiri-styles/propset'

module NokogiriStyles
  module NodeStyles
    def styles
      return NokogiriStyles::Propset.new(self['style'] || '')
    end

    def styles=(value)
      self['style'] = value.to_s
    end

    def classes
      return self['class'].split(' ')
    end

    def classes=(value)
      self['class'] = value.join(' ')
    end
  end
end
