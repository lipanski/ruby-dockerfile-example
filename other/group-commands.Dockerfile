FROM ruby:2.5.5

# We usually only need to run this once
RUN apt update && \
  apt install -y mysql-client postgresql-client nginx

# We usually run this every time we add a new dependency
RUN bundle install

CMD ruby -e "puts 1 + 2"
