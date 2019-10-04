FROM ruby:2.5.5-alpine AS builder

# A Gemfile that contains a test dependency (minitest)
RUN echo 'source "https://rubygems.org"; gem "sinatra"; group(:test) { gem "minitest" }' > Gemfile
RUN echo 'require "sinatra"; run Sinatra::Application.run!' > config.ru

# By default we don't install development or test dependencies
RUN bundle install --without development test

# A separate build stage installs test dependencies and runs your tests
FROM builder AS test
# The test stage installs the test dependencies
RUN bundle install --with test
# Let's introduce a test that passes
RUN echo 'require "minitest/spec"; require "minitest/autorun"; class TestIndex < MiniTest::Test; def test_it_passes; assert(true); end; end' > test.rb
# The actual test run
RUN bundle exec ruby test.rb

# The production artifact doesn't contain any test dependencies
FROM ruby:2.5.5-alpine

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /config.ru ./

CMD ["rackup"]
