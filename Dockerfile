# Stage 1: Base stage for building gems
FROM ruby:3.1.4-slim as base

# Set working directory
WORKDIR /rails

# Install OS-level dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libvips \
        pkg-config \
        curl \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Build stage for installing gems
FROM base as build

# Set environment variables for Bundler
ENV BUNDLE_DEPLOYMENT=true \
    BUNDLE_WITHOUT='development:test'

# Copy and install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs "$(nproc)" --retry 5 --path=/usr/local/bundle

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Copy docker-entrypoint script
COPY docker-entrypoint /rails/docker-entrypoint
RUN chmod +x /rails/docker-entrypoint

# Verify if the file is copied correctly
RUN ls -l /rails/docker-entrypoint

# Stage 3: Final stage for app image
FROM base

# Set working directory
WORKDIR /rails

# Copy built artifacts: gems, application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Copy master.key and set permissions (before changing to the rails user)
COPY ../config/master.key /rails/config/master.key
RUN chmod 600 /rails/config/master.key

# Ensure necessary directories exist (before changing to the rails user)
RUN mkdir -p /rails/db /rails/log /rails/storage /rails/tmp

# Create a non-root user for running the application (after privileged operations)
RUN useradd -m rails && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp

# Verify the existence and permissions of the docker-entrypoint file
RUN ls -l /rails/docker-entrypoint

# Switch to the non-root user
USER rails

# Entrypoint prepares the database and starts the server
ENTRYPOINT ["/rails/docker-entrypoint"]

# Expose port 3000
EXPOSE 3000

# Default command to start the Rails server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
