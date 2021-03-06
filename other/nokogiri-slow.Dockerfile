FROM ruby:2.5.5

RUN echo 'source "https://rubygems.org"; gem "nokogiri"' > Gemfile

RUN bundle install
