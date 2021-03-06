# Start from a small, trusted base image with the version pinned down
FROM ruby:2.7.1-alpine AS base

# Install system dependencies required both at runtime and build time
# The image uses Postgres but you can swap it with mariadb-dev (for MySQL) or sqlite-dev
RUN apk add --update \
  postgresql-dev \
  tzdata

# This stage will be responsible for installing gems
FROM base AS dependencies

# Install system dependencies required to build some Ruby gems (pg)
RUN apk add --update build-base

COPY Gemfile Gemfile.lock ./

# Install gems (excluding development/test dependencies)
RUN bundle config set without "development test" && \
  bundle install --jobs=3 --retry=3

# We're back at the base stage
FROM base

# Create a non-root user to run the app and own app-specific files
RUN adduser -D app

# Switch to this user
USER app

# We'll install the app in this directory
WORKDIR /home/app

# Copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY --chown=app . ./

# Launch the server (or run some other Ruby command)
CMD ["bundle", "exec", "rackup"]
