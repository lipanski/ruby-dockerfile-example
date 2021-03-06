# Start from a small, trusted base image with the version pinned down
FROM ruby:2.7.1-alpine AS base

# Install system dependencies required both at runtime and build time
# The image uses Postgres but you can swap it with mariadb-dev (for MySQL) or sqlite-dev
RUN apk add --update \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn

# This stage will be responsible for installing gems and npm packages
FROM base AS dependencies

# The argument is required later, when installing private gems or npm packages
ARG GITHUB_TOKEN

# Install system dependencies required to build some Ruby gems (pg)
RUN apk add --update build-base

COPY Gemfile Gemfile.lock ./

# Don't install development or test dependencies
RUN bundle config set without "development test"

# Install gems (including private ones)
# This uses the GITHUB_TOKEN argument, which is also cleaned up in the same step
RUN git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/some-user".insteadOf git@github.com:some-user && \
  git config --global --add url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/some-user".insteadOf ssh://git@github && \
  bundle install --jobs=3 --retry=3 && \
  rm ~/.gitconfig

COPY package.json yarn.lock ./

# Install npm packages (including private ones)
# This uses the GITHUB_TOKEN argument, which is also cleaned up in the same step
RUN git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/some-user".insteadOf git@github.com:some-user && \
  git config --global --add url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/some-user".insteadOf ssh://git@github && \
  yarn install --frozen-lockfile \
  rm ~/.gitconfig

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

# Copy over npm packages from the dependencies stage
# Note that we have to use `--chown` here
COPY --chown=app --from=dependencies /node_modules/ node_modules/

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY --chown=app . ./

# Install assets
RUN RAILS_ENV=production SECRET_KEY_BASE=assets bundle exec rake assets:precompile

# Launch the server
CMD ["bundle", "exec", "rackup"]
