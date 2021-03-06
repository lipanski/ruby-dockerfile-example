FROM ruby:2.5.5-alpine

ARG PRIVATE_SSH_KEY

# Let's create a basic Gemfile
RUN echo 'source "https://rubygems.org"; gem "sinatra"' > Gemfile

RUN mkdir -p /root/.ssh/ && \
  echo "${PRIVATE_SSH_KEY}" > /root/.ssh/id_rsa && \
  bundle install && \
  rm /root/.ssh/id_rsa

CMD ruby -e "puts 1 + 2"
