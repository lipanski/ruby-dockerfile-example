# 1. Pin your base image version
# 2. Use only trusted or official base images
# 12. Minimize image size by opting for small base images when possible
# 13. Use multi-stage builds to reduce the size of your image
# 14. Use multi-stage builds to avoid leaking secrets inside your docker history
FROM ruby:2.5.5-alpine AS builder

# 9. Avoid leaking secrets inside your image
# 11. Fetching private dependencies via a Github token injected through the gitconfig
# 14. Use multi-stage builds to avoid leaking secrets inside your docker history
ARG GITHUB_TOKEN

# 5. Group commands by how likely they are to change individually
# 6. Place the least likely to change commands at the top
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  git

# 4. Pin your application dependencies (Gemfile.lock)
COPY Gemfile Gemfile.lock ./

# 10. Always clean up injected secrets within the same build step
# 11. Fetching private dependencies via a Github token injected through the gitconfig
# 14. Use multi-stage builds to avoid leaking secrets inside your docker history
RUN git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/some-user".insteadOf git@github.com:some-user && \
  git config --global --add url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/some-user".insteadOf ssh://git@github && \
  bundle install --without development test && \
  rm ~/.gitconfig

# 16. Optional: Combine production, test and development build processes into a single Dockerfile by using multi-stage builds
FROM builder AS test
RUN bundle install --with test
COPY test.rb ./
RUN bundle exec ruby test.rb

# 1. Pin your base image version
# 2. Use only trusted or official base images
# 12. Minimize image size by opting for small base images when possible
# 13. Use multi-stage builds to reduce the size of your image
# 14. Use multi-stage builds to avoid leaking secrets inside your docker history
FROM ruby:2.5.5-alpine

# 13. Use multi-stage builds to reduce the size of your image
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# 7. Avoid running your application as root
RUN adduser -D myuser
USER myuser
WORKDIR /home/myuser

# 8. When running COPY or ADD (as a different user) use --chown
COPY --chown=myuser . ./

# 15. When setting the CMD instruction, prefer the exec format over the shell format
CMD ["bundle", "exec", "rackup"]
