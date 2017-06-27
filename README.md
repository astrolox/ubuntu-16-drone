Repackaging of Drone with the 1&1 root and issuing certificates installed.

[Drone](https://github.com/drone/drone) is a Continuous Delivery system built on container technology. Drone uses a simple yaml configuration file, a superset of docker-compose, to define and execute Pipelines inside Docker containers.

A multistage Dockerfile (`Dockerfile-multistage`) is provided which requires docker 17.05

Alternatively the two steps can be run separately:

1. Use `Dockerfile-build` to build the drone binary
2. Copy it into your working directory:

   `docker run -v `pwd`:/tmp/drone drone-build cp /go/src/github.com/drone/drone/release/drone /tmp/drone`

3. Build the final image

   `docker build -t drone .` 


Note that the default `Dockerfile` expects a compiled drone binary to be present in the working directory which it copies into the image


