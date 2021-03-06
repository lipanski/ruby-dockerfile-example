FROM ruby:2.5.5

RUN echo 'source "https://rubygems.org"; gem "sinatra"' > Gemfile
RUN bundle install

# A simple Sinatra app which prints out HUUUUUP when the process receives the HUP signal.
RUN echo 'require "sinatra"; set bind: "0.0.0.0"; Signal.trap("HUP") { puts "HUUUUUP" }; run Sinatra::Application.run!' > config.ru

CMD ["bundle", "exec", "rackup"]
