# frozen_string_literal: true

class WordToMarkdown
  # Removes links and images with unsafe URL schemes (e.g., javascript: or
  # vbscript:) so that they don't survive into the markdown output
  module UrlScrubber
    # URL schemes permitted in link targets. Links with any other scheme are
    # unwrapped to their text. Relative URLs and fragments are always permitted.
    SAFE_LINK_SCHEMES = %w[http https mailto].freeze

    # URL schemes permitted in image sources, in addition to data:image/ URIs.
    # Images with any other scheme are removed.
    SAFE_IMAGE_SCHEMES = %w[http https].freeze

    # Browsers remove ASCII tabs and newlines anywhere in a URL, and C0
    # control characters and spaces at either end, before parsing the scheme
    STRIPPED_CHARS = /[\t\n\r]/
    EDGE_CHARS = /\A[\x00-\x20]+|[\x00-\x20]+\z/

    # Matches a URL scheme, e.g., "https:"
    SCHEME_REGEX = /\A([a-z][a-z0-9+.-]*):/i

    # Matches a data URI for an image
    DATA_IMAGE_REGEX = %r{\Adata:image/}i

    class << self
      # Unwrap links and remove images whose URL scheme isn't permitted
      #
      # @param tree [Nokogiri::HTML::Document] the document to scrub, in place
      # @return [Nokogiri::HTML::Document] the scrubbed document
      def scrub!(tree)
        tree.css('a[href]').each do |node|
          node.replace(node.children) unless safe_link?(node['href'])
        end

        tree.css('img[src]').each do |node|
          node.remove unless safe_image?(node['src'])
        end

        tree
      end

      # @param url [String] a link target
      # @return [Boolean] true if the URL is relative, a fragment, or has a permitted scheme
      def safe_link?(url)
        scheme = scheme(url)
        scheme.nil? || SAFE_LINK_SCHEMES.include?(scheme)
      end

      # @param url [String] an image source
      # @return [Boolean] true if the URL is relative, a data:image/ URI, or has a permitted scheme
      def safe_image?(url)
        scheme = scheme(url)
        scheme.nil? || SAFE_IMAGE_SCHEMES.include?(scheme) || normalize(url).match?(DATA_IMAGE_REGEX)
      end

      # @param url [String] the URL
      # @return [String, nil] the URL's lowercased scheme, or nil if it has none
      def scheme(url)
        match = normalize(url).match(SCHEME_REGEX)
        match && match[1].downcase
      end

      private

      # Normalize a URL the way a browser does before parsing its scheme
      #
      # @param url [String] the URL
      # @return [String] the normalized URL
      def normalize(url)
        url.to_s.gsub(STRIPPED_CHARS, '').gsub(EDGE_CHARS, '')
      end
    end
  end
end
