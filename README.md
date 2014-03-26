# Word to Markdown converter

A Ruby gem to liberate content from [the jail that is Word documents](http://ben.balter.com/2012/10/19/we-ve-been-trained-to-make-paper/#jailbreaking-content)

[![Build Status](https://travis-ci.org/benbalter/word-to-markdown.svg?branch=master)](https://travis-ci.org/benbalter/word-to-markdown) [![Gem Version](https://badge.fury.io/rb/word-to-markdown.png)](http://badge.fury.io/rb/word-to-markdown) [![Inline docs](http://inch-pages.github.io/github/benbalter/word-to-markdown.png)](http://inch-pages.github.io/github/benbalter/word-to-markdown)

## The problem

*Link to blog post here*

**[Demo](http://word-to-markdown.herokuapp.com/)**

## Getting HTML content out of Microsoft Word

1. Open the file in Microsoft Word
2. Select "File" -> "Save as Web Page"
3. Hit save

## Usage

```ruby
doc = WordToMarkdown.new("/path/to/export.htm")
=> <WordToMarkdown path="/path/to/export.htm">

doc.to_s
=> "# Test\n\n This is a test"

doc.html
=> "<html>\n\n<head>..."

doc.doc
=> <Nokogiri Document>
```

## Supports

* Paragraphs
* Numbered lists
* Unnumbered lists
* Italic
* Bold
* Explicit headings (e.g., selected as "Heading 1" or "Heading 2")
* Implicit headings (e.g., text with a larger font size relative to paragraph text)
* Images
* Tables

## Future Support

* Nested lists

## Testing

`script/cibuild`

## Server

The development version of the gem contains a lightweight server for converting Word Documents as a service.

To run the server, simply run `script/server` and open `localhost:9292` in your browser. The server can also be run on Heroku.

A live version runs at [word-to-markdown.herokuapp.com](http://word-to-markdown.herokuapp.com).

You can also use it as a service by posting raw HTML to `/raw`, which will return the raw markdown in response.
