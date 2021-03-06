FROM ruby

COPY . ./

RUN bundle install

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y ruby-dev

CMD bundle exec rackup
