FROM ruby:3.3.5 AS builder

# Install dependencies for building Jekyll
RUN apt-get update -qq && apt-get install -y build-essential nodejs

# Set working directory
WORKDIR /srv/jekyll

# Copy Gemfile and install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy project files and fix permissions
COPY . .
RUN chown 1000:1000 -R /srv/jekyll

# Build the Jekyll site
RUN bundle exec jekyll build -d /srv/jekyll/_site

# -------------------------------
# Stage 2: Final lightweight Nginx server
FROM nginx:alpine

# Copy built site from the builder stage
COPY --from=builder /srv/jekyll/_site /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
