FROM ruby:2.5.5

ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev

RUN echo 'source "https://rubygems.org"; gem "nokogiri"' > Gemfile

RUN bundle install
