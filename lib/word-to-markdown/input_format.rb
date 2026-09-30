# frozen_string_literal: true

class WordToMarkdown
  # Identifies Word documents by their content, rather than their extension,
  # so that other formats LibreOffice would otherwise sniff and import (e.g.,
  # HTML, which can reference remote resources) are never passed to it
  module InputFormat
    # Signature of an OLE compound file, used by .doc files
    OLE_SIGNATURE = "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1".b.freeze

    # Signature of a ZIP local file header, used by .docx files
    ZIP_SIGNATURE = "PK\x03\x04".b.freeze

    # Signature of a ZIP end of central directory record
    ZIP_EOCD_SIGNATURE = "PK\x05\x06".b.freeze

    # Size of the end of central directory record, excluding the comment
    ZIP_EOCD_SIZE = 22

    # Maximum length of a ZIP archive comment
    ZIP_MAX_COMMENT_SIZE = 0xFFFF

    # The main document part every Word OOXML package contains
    OOXML_DOCUMENT_PART = 'word/document.xml'.b.freeze

    # LibreOffice import filters, by format
    FILTERS = {
      ooxml: 'MS Word 2007 XML',
      ole: 'MS Word 97'
    }.freeze

    class << self
      # @param path [String] path to the file
      # @return [String, nil] the LibreOffice import filter for the file, or nil if it isn't a Word document
      def filter_for(path)
        FILTERS[detect(path)]
      end

      # @param path [String] path to the file
      # @return [Symbol, nil] :ooxml for .docx, :ole for .doc, or nil if it isn't a Word document
      def detect(path)
        File.open(path, 'rb') do |file|
          signature = file.read(OLE_SIGNATURE.bytesize).to_s
          if signature == OLE_SIGNATURE
            :ole
          elsif signature.start_with?(ZIP_SIGNATURE) && ooxml_document?(file)
            :ooxml
          end
        end
      end

      private

      # @param file [File] an open ZIP file
      # @return [Boolean] true if the ZIP's central directory lists the Word main document part
      def ooxml_document?(file)
        directory = central_directory(file)
        !directory.nil? && directory.include?(OOXML_DOCUMENT_PART)
      end

      # Read the ZIP central directory, whose entries include each file name, uncompressed
      #
      # @param file [File] an open ZIP file
      # @return [String, nil] the raw central directory, or nil if it can't be found
      def central_directory(file)
        size, offset = central_directory_location(file)
        return if size.nil? || offset + size > file.size

        file.seek(offset)
        file.read(size)
      end

      # @param file [File] an open ZIP file
      # @return [Array<Integer>, nil] the central directory's size and offset, or nil if not found
      def central_directory_location(file)
        tail_size = [file.size, ZIP_EOCD_SIZE + ZIP_MAX_COMMENT_SIZE].min
        file.seek(-tail_size, IO::SEEK_END)
        tail = file.read(tail_size)
        index = tail.rindex(ZIP_EOCD_SIGNATURE)
        return if index.nil? || tail.bytesize - index < ZIP_EOCD_SIZE

        tail.byteslice(index + 12, 8).unpack('VV')
      end
    end
  end
end
