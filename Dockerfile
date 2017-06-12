FROM plugins/drone-git
MAINTAINER brian.wojtczak@1and1.co.uk

RUN cd /usr/share/ca-certificates/ && \
	mkdir 1and1 && \
	cd 1and1 && \
	wget http://pub.pki.1and1.org/pukirootca1.crt && \
	wget http://pub.pki.1and1.org/pukiissuingca1.crt && \
	cd .. && \
	ls -1 1and1/* >>  /etc/ca-certificates.conf && \
	apk add ca-certificates && \
	update-ca-certificates

COPY entrypoint-script /bin/
ENTRYPOINT /bin/entrypoint-script

