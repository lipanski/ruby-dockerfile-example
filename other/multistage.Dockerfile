FROM ruby:2.5.5-alpine as builder

RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev

RUN echo 'source "https://rubygems.org"; gem "nokogiri"' > Gemfile

RUN bundle install

FROM ruby:2.5.5-alpine

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

CMD /bin/sh
