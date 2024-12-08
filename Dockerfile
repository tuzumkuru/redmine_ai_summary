FROM redmine:5.1-bookworm
RUN apt update && apt install -y gcc make supervisor
COPY ./Gemfile /usr/src/redmine/plugins/redmine_ai_summary/Gemfile
RUN bundle install --with=development
RUN echo "development:\n  adapter: sqlite3\n  database: /usr/src/redmine/sqlite/redmine.db" > /usr/src/redmine/config/database.yml
RUN sed -i '/^end$/i config.hosts.clear' /usr/src/redmine/config/environments/development.rb
RUN mkdir -p /usr/src/redmine/sqlite
RUN chown -R 999:999 /usr/src/redmine/sqlite

WORKDIR /usr/src/redmine

# COPY lib/tasks/create_test_data.rake lib/tasks/

ENTRYPOINT [ "" ]
CMD [ "/bin/sh", "-c", "export RAILS_ENV=development &&  rails db:migrate && rails redmine:plugins:migrate && echo 'en' | rails redmine:load_default_data && rails server -e development -b 0.0.0.0" ]