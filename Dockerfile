###### compute node
# runs slurmd, sshd and is able to execute jobs via mpi
FROM qnib/terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

# carboniface
ADD yum-cache/carboniface /tmp/yum-cache/carboniface
RUN yum install -y python-docopt /tmp/yum-cache/carboniface/python-carboniface-1.0.3-1.x86_64.rpm

# graphite-web
RUN 	yum install -y nginx python-django python-whisper python-django-tagging pyparsing pycairo python-gunicorn pytz 
RUN 	useradd www-data
RUN 	mkdir -p /var/lib/graphite-web/log/webapp
ADD     ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD     ./etc/nginx/conf.d/diamond.conf /etc/nginx/conf.d/
ADD     ./etc/nginx/conf.d/graphite-web.conf /etc/nginx/conf.d/
WORKDIR /usr/share
ADD     ./graphite-web.tar /usr/share/

## Diamond
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

#### Config
## graphite web
ADD     ./local_settings.py /usr/share/graphite-web/webapp/graphite/
ADD     ./initial_data.json /usr/share/graphite-web/webapp/initial_data.json
WORKDIR /usr/share/graphite-web/webapp/
RUN 	python manage.py syncdb --noinput
RUN 	chown www-data:www-data -R /var/lib/graphite-web/
ADD     etc/supervisord.d/nginx.ini /etc/supervisord.d/
ADD 	etc/supervisord.d/graphite-web.ini /etc/supervisord.d/


# tidy up
RUN 	rm -f /usr/share/graphite-web/webapp/initial_data.json
RUN 	rm -rf /tmp/rpms


CMD /bin/supervisord -c /etc/supervisord.conf
