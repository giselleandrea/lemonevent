# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.1.4

# Stage 1: Base stage for building gems
FROM ruby:$RUBY_VERSION-slim as base

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

# Stage 3: Final stage for app image
FROM base

# Set working directory
WORKDIR /rails

# Copy built artifacts: gems, application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Copy master.key and set permissions (antes de cambiar al usuario rails)
COPY config/master.key /rails/config/master.key
RUN chmod 600 /rails/config/master.key

# Ensure necessary directories exist (antes de cambiar al usuario rails)
RUN mkdir -p /rails/db /rails/log /rails/storage /rails/tmp

# Create a non-root user for running the application (después de las operaciones que requieren permisos elevados)
RUN useradd -m rails && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp

# Switch to the non-root user
USER rails

# Entrypoint prepares the database and starts the server
ENTRYPOINT ["/rails/docker-entrypoint"]

# Expose port 3000
EXPOSE 3000

# Default command to start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
