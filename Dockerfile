FROM ruby:2.5

RUN bundle config --global frozen 1

RUN apt-get update

# Libre libreoffice
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:libreoffice/ppa
RUN apt-get install -y --no-install-recommends libreoffice-writer

RUN soffice --version

COPY Gemfile Gemfile.lock word-to-markdown.gemspec ./
COPY lib/word-to-markdown/version.rb ./lib/word-to-markdown/version.rb
RUN bundle install

COPY . .

WORKDIR /app

CMD echo "Nothing to run"
