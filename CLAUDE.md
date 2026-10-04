# CLAUDE.md

Word to Markdown is a Ruby gem and `w2m` CLI that converts Word documents to Markdown through LibreOffice. New work mostly happens in its successor, [word-to-markdown-js](https://github.com/benbalter/word-to-markdown-js).

## Commands

- [`script/bootstrap`](script/bootstrap) runs `bundle install`.
- [`script/cibuild`](script/cibuild) runs the tests, RuboCop and a gem build. It's what CI runs, so run it before committing. The tests need LibreOffice (`soffice`) installed; without it, use the Docker setup in the [README](README.md#docker).

## Releasing

There's no release script or workflow. A release is a "Release X.Y.Z" commit that bumps [`lib/word-to-markdown/version.rb`](lib/word-to-markdown/version.rb), a `vX.Y.Z` tag, a GitHub Release with generated notes, and the gem pushed to [RubyGems](https://rubygems.org/gems/word-to-markdown).

Releases happen only after the owner explicitly approves them. Agents may open a PR that bumps the version, but must never push a tag, run `gem push`, or create a GitHub Release. A published gem version can't be reused, even if it's yanked.
