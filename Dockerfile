FROM ruby:2.5

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ghostscript \
      libfontconfig \
      libreoffice-writer \
      libxslt1-dev

RUN gem install word-to-markdown --no-rdoc --no-ri

WORKDIR /app

CMD echo "Nothing to run"
