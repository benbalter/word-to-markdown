# Word to Markdown converter

> [!IMPORTANT]
> **Looking for the latest and greatest?** Check out [**word-to-markdown-js**](https://github.com/benbalter/word-to-markdown-js), the newer, better successor to this project. It's a modern, actively maintained rewrite and is recommended for new projects. This Ruby gem remains available for existing users.

A Ruby gem to liberate content from [the jail that is Word documents](https://ben.balter.com/2012/10/19/we-ve-been-trained-to-make-paper/#jailbreaking-content)

[![CI](https://github.com/benbalter/word-to-markdown/actions/workflows/ci.yml/badge.svg)](https://github.com/benbalter/word-to-markdown/actions/workflows/ci.yml) [![Gem Version](https://img.shields.io/gem/v/word-to-markdown)](https://rubygems.org/gems/word-to-markdown)

## The problem

> Our default content publishing workflow is terribly broken. [We've all been trained to make paper](https://ben.balter.com/2012/10/19/we-ve-been-trained-to-make-paper/), yet today, content authored once is more commonly consumed in multiple formats, and rarely, if ever, does it embody physical form. Put another way, our go-to content authoring workflow remains relatively unchanged since it was conceived in the early 80s.
>
> I'm asked regularly by government employees — knowledge workers who fire up a desktop word processor as the first step to any project — for an automated pipeline to convert Microsoft Word documents to [Markdown](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax), the *lingua franca* of the internet, but as my recent foray into building [just such a converter](https://word2md.com/) proves, it's not that simple.
>
> Markdown isn't just an alternative format. Markdown forces you to write for the web.

**[Read more](https://ben.balter.com/2014/03/31/word-versus-markdown-more-than-mere-semantics/)**

## Just want to convert a Microsoft Word (or Google) document to Markdown?

You can use this **[hosted service](https://word2md.com/)** (or check out [its source](https://github.com/benbalter/word-to-markdown-js)).

## Install

You'll need to install [LibreOffice](https://www.libreoffice.org/). Then:

```bash
gem install word-to-markdown
```

## Usage

```ruby
file = WordToMarkdown.new("/path/to/document.docx")
=> <WordToMarkdown path="/path/to/document.docx">

file.to_s
=> "# Test\n\n This is a test"

file.document.tree
=> <Nokogiri Document>
```

### Command line usage

Once you've installed the gem, it's just:

```
$ w2m path/to/document.docx
```

*Outputs the resulting markdown to stdout*

## Supports

* Paragraphs
* Numbered lists
* Unnumbered lists
* Nested lists
* Italic
* Bold
* Explicit headings (e.g., selected as "Heading 1" or "Heading 2")
* Implicit headings (e.g., text with a larger font size relative to paragraph text)
* Images
* Tables
* Hyperlinks

## Requirements and configuration

Word-to-markdown requires `soffice` a command line interface to LibreOffice that works on Linux, Mac, and Windows. To install soffice, see [the LibreOffice documentation](https://www.libreoffice.org/get-help/install-howto/).

Word-to-markdown only accepts Word documents (`.docx` and `.doc`), identified by their contents rather than their file extension. Other files, including those LibreOffice could otherwise open, such as HTML, ODT, or RTF, raise `WordToMarkdown::Document::UnsupportedFormatError`.

LibreOffice is killed if a conversion takes longer than 60 seconds, raising `WordToMarkdown::TimeoutError`. To change the limit, set `WordToMarkdown.timeout = 120` or the `WORD_TO_MARKDOWN_TIMEOUT` environment variable.

### Converting untrusted documents

Word documents can link to remote resources, such as images, which LibreOffice fetches while converting the document. If you convert documents from untrusted sources (for example, files uploaded to a web service), run the conversion without network access, such as in a container or sandbox with no outbound network, so that a document can't make requests to internal services or other hosts on your behalf.

## Testing

```
script/cibuild
```

## Docker

Everything you need to run the executable locally:

```
docker compose build
docker compose run --rm app bundle exec w2m --help
docker compose run --rm app bundle exec w2m test/fixtures/em.docx
```

## Hosted service

A hosted converter runs at [word2md.com](https://word2md.com), powered by [word-to-markdown-js](https://github.com/benbalter/word-to-markdown-js). The previous Ruby-based [word-to-markdown-server](https://github.com/benbalter/word-to-markdown-server) is archived.
