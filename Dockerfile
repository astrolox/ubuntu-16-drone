FROM 1and1internet/ubuntu-16:unstable
MAINTAINER james.eckersall@fasthosts.co.uk
ARG DEBIAN_FRONTEND=noninteractive
#COPY files/ /
ARG GOPATH=/opt/drone
ARG PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/go/bin:/opt/drone/bin

RUN \
  apt-get -y update && \
  apt-get -o Dpkg::Options::=--force-confdef -y install golang git golang-github-elazarl-go-bindata-assetfs-dev && \
  mkdir --mode=755 $GOPATH $GOPATH/src $GOPATH/bin $GOPATH/pkg -p
RUN \
  git clone https://github.com/drone/drone $GOPATH/src/github.com/drone/drone
RUN \
  git -C $GOPATH/src/github.com/drone/drone checkout b354b93658718c5c097309a7c98b5c7f5902048a
RUN go get -u github.com/Sirupsen/logrus
RUN go get -u github.com/gin-gonic/contrib/ginrus
RUN go get -u github.com/ianschenck/envflag
RUN go get -u github.com/joho/godotenv
RUN go get -u github.com/joho/godotenv/autoload
RUN \
  $GOPATH/src/github.com/drone/drone/contrib/setup-sassc.sh && \
  $GOPATH/src/github.com/drone/drone/contrib/setup-sqlite.sh
RUN \
  export PATH=$PATH:/usr/lib/go/bin:/opt/drone/bin && \
  cd $GOPATH/src/github.com/drone/drone && \
  make deps && \
  go generate github.com/drone/drone/static && \
  go generate github.com/drone/drone/template && \
  go generate github.com/drone/drone/store/datastore/ddl && \
  go build --ldflags '-extldflags "-static"' -o /opt/drone/drone_static

EXPOSE 8000
ENTRYPOINT [ "/opt/drone/drone_static" ]
