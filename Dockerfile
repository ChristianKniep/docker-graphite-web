###### compute node
# runs slurmd, sshd and is able to execute jobs via mpi
FROM qnib/terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

##### USER
# Set (very simple) password for root
RUN echo "root:root"|chpasswd
ADD root/ssh /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 644 /root/.ssh/id_rsa.pub
RUN chown -R root:root /root/*

### SSHD
RUN yum install -y openssh-server
RUN mkdir -p /var/run/sshd
RUN sshd-keygen
RUN sed -i -e 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
ADD root/ssh /root/.ssh/
ADD etc/supervisord.d/sshd.ini /etc/supervisord.d/sshd.ini

# We do not care about the known_hosts-file and all the security
####### Highly unsecure... !1!! ###########
RUN echo "        StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "        UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
RUN echo "        AddressFamily inet" >> /etc/ssh/ssh_config

# carboniface
ADD yum-cache/carboniface /tmp/yum-cache/carboniface
RUN yum install -y python-docopt /tmp/yum-cache/carboniface/python-carboniface-1.0.3-1.x86_64.rpm

# graphite-web
RUN 	yum install -y nginx python-django python-django-tagging pyparsing pycairo python-gunicorn pytz git-core
RUN 	useradd www-data
RUN 	mkdir -p /var/lib/graphite-web/log/webapp
ADD     ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
WORKDIR /usr/share
RUN 	git clone https://github.com/graphite-project/graphite-web.git

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
