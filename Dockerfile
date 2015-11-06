###### QNIBTerminal
FROM qnib/u-terminal

# Postgresql
RUN apt-get install -y sudo postgresql libpq-dev python-psycopg2
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER graphite WITH PASSWORD 'password';" && \
    sudo -u postgres psql -c "CREATE DATABASE graphite WITH OWNER graphite;"
ADD etc/supervisord.d/postgres.ini /etc/supervisord.d/
## Graphite-web
RUN apt-get install -y graphite-web
ADD etc/graphite/local_settings.py etc/graphite/init_data.json /etc/graphite/
RUN service postgresql start && \
    cd /etc/graphite/ && \
    graphite-manage syncdb --noinput
RUN touch /var/lib/graphite/search_index 
## Apache2
RUN apt-get install -y apache2 libapache2-mod-wsgi
RUN a2dissite 000-default && \
    cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available && \
    a2ensite apache2-graphite && \
    chown -R www-data: /var/lib/graphite/
ADD etc/supervisord.d/apache2.ini /etc/supervisord.d/

