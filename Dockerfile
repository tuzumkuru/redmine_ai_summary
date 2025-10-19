FROM redmine:6

# Install required packages
RUN apt update && apt install -y gcc make supervisor

# Copy Gemfile for your plugin
COPY ./Gemfile /usr/src/redmine/plugins/redmine_ai_summary/Gemfile
RUN bundle install --with=development

# Set up SQLite database
RUN echo "development:\n  adapter: sqlite3\n  database: /usr/src/redmine/sqlite/redmine.db" > /usr/src/redmine/config/database.yml
RUN mkdir -p /usr/src/redmine/sqlite && chown -R 999:999 /usr/src/redmine/sqlite

# Adjust Rails environment settings
RUN sed -i '/^end$/i config.hosts.clear' /usr/src/redmine/config/environments/development.rb

# Copy custom rake task
COPY lib/tasks/create_test_data.rake lib/tasks/
COPY lib/tasks/set_admin_password.rake lib/tasks/

# Switch working directory
WORKDIR /usr/src/redmine

# Set up the entrypoint and commands
CMD ["/bin/bash", "-c", " \
    rm -f /usr/src/redmine/tmp/pids/server.pid && \
    export RAILS_ENV=development && \
    bundle install && \
    rails db:migrate && \
    rails redmine:plugins:migrate && \
    if [ ! -f /usr/src/redmine/sqlite/.initialized ]; then \
        echo 'en' | rails redmine:load_default_data && \
        rails redmine:create_test_data && \
        rails redmine:set_admin_password && \
        touch /usr/src/redmine/sqlite/.initialized; \
    fi && \
    rails server -e development -b 0.0.0.0"]
