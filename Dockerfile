###### QNIBTerminal
FROM qnib/nginx

# graphite-web
RUN dnf install -y python-django python-whisper python-django-tagging pyparsing pycairo python-gunicorn pytz 
RUN mkdir -p /var/lib/graphite-web/log/webapp
ADD etc/nginx/nginx.conf /etc/nginx/
ADD etc/nginx/conf.d/diamond.conf etc/nginx/conf.d/graphite-web.conf /etc/nginx/conf.d/
RUN curl -fsL https://github.com/graphite-project/graphite-web/archive/master.zip | bsdtar xf - -C /usr/share/ && \
    mv /usr/share/graphite-web-master /usr/share/graphite-web

#### Config
RUN mkdir -p /usr/share/graphite-web/storage/log/webapp
## graphite web
#ADD     ./local_settings.py /usr/share/graphite-web/webapp/graphite/
#ADD     ./initial_data.json /usr/share/graphite-web/webapp/initial_data.json
RUN cd /usr/share/graphite-web/webapp/ && \
    python manage.py syncdb --noinput && \
    chown nginx: -R /var/lib/graphite-web/
ADD etc/supervisord.d/graphite-web.ini /etc/supervisord.d/


# tidy up
RUN 	rm -f /usr/share/graphite-web/webapp/initial_data.json
