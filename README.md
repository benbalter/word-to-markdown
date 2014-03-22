# Word to Markdown converter

A Ruby gem to liberate content from [the jail that is Word documents](http://ben.balter.com/2012/10/19/we-ve-been-trained-to-make-paper/#jailbreaking-content)

## The problem

*Link to blog post here*

## Getting content out of Microsoft Word

1. Open the file in Microsoft Word
2. Select "File" -> "Save as Web Page"
3. Select "Formatting information only"
4. Hit save

## Usage

```ruby
doc = WordToMarkdown.new("path/to/export.htm")
doc.to_s
=> "# Test\n\n This is a test"

doc.html
=> "<html><head>..."

doc.doc
=> <Nokogiri Document>
```

## Supports

* Numbered lists
* Unnumbered lists
* Italic
* Bold
* Explicit headings (e.g., selected as "Heading 1" or "Heading 2")
* Paragraphs

## Future Support

* Nested lists

## Testing

`script/cibuild`
