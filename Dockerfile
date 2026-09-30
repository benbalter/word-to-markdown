FROM ruby:4.0

RUN apt-get update \
  && apt-get install -y --no-install-recommends libreoffice-writer \
  && rm -rf /var/lib/apt/lists/*

RUN soffice --version

WORKDIR /app

COPY Gemfile word-to-markdown.gemspec ./
COPY lib/word-to-markdown/version.rb ./lib/word-to-markdown/version.rb
RUN bundle install

COPY . .

CMD ["bundle", "exec", "w2m", "--help"]
