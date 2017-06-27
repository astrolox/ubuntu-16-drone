FROM 1and1internet/ubuntu-16:latest
LABEL maintainer "hamish.robertson@1and1.co.uk"
RUN cd /usr/share/ca-certificates/ && \
  mkdir 1and1 && \
  cd 1and1 && \
  wget http://pub.pki.1and1.org/pukirootca1.crt && \
  wget http://pub.pki.1and1.org/pukiissuingca1.crt && \
  openssl x509 -noout -in pukirootca1.crt -fingerprint -sha256 >a && \
  echo "SHA256 Fingerprint=6B:DE:2B:46:BA:BF:52:1E:09:45:41:16:AE:CD:73:65:DE:79:EB:D9:49:FE:B3:9C:E9:F1:1C:2B:46:60:C0:CD" | diff a - && \
  openssl x509 -noout -in pukiissuingca1.crt -fingerprint -sha256 >b && \
  echo "SHA256 Fingerprint=E1:99:91:7B:7F:DE:02:AF:00:AC:D0:65:0D:7B:E0:42:2A:A6:8E:E4:C1:53:BA:12:EF:15:3D:DB:62:A2:9A:DC" | diff b - && \
  rm a b && \
  cd .. && \
  ls -1 1and1/* >>  /etc/ca-certificates.conf && \
  update-ca-certificates

ARG DEBIAN_FRONTEND=noninteractive

COPY drone /opt/drone/drone

EXPOSE 8000 80 443
ENTRYPOINT [ "/opt/drone/drone" ]
CMD ["server"]