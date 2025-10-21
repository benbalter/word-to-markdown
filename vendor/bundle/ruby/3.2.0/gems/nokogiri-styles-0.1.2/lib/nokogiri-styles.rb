require 'nokogiri-styles/version'
require 'nokogiri-styles/node_styles'

module Nokogiri::XML
  class Node
    include NokogiriStyles::NodeStyles
  end
end
