FROM redmine:5.1-bookworm

RUN apt update && apt install -y gcc make supervisor
COPY ./Gemfile /usr/src/redmine/plugins/redmine_ai_summary/Gemfile
RUN bundle install --with=development

RUN echo "development:\n  adapter: sqlite3\n  database: /usr/src/redmine/sqlite/redmine.db" > /usr/src/redmine/config/database.yml
RUN sed -i '/^end$/i config.hosts.clear' /usr/src/redmine/config/environments/development.rb
RUN mkdir -p /usr/src/redmine/sqlite
RUN chown -R 999:999 /usr/src/redmine/sqlite

# Write supervisord.conf directly into the container
RUN echo '[supervisord]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '[unix_http_server]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'file=/var/run/supervisor.sock   ; (the path to the socket file)' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'chmod=0700                       ; socket file mode (default 0700)' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '[rpcinterface:supervisor]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '[program:redmine]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'command=/usr/local/bin/ruby /usr/src/redmine/bin/rails server -e development -b 0.0.0.0' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'directory=/usr/src/redmine' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'startsecs=10' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'stopasgroup=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'killsignal=SIGQUIT' >> /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]
