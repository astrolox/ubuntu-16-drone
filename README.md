
# Ubuntu 16.04 LTS (Xenial Xerus) with Drone CI

This image repackages a specific version of [Drone](https://github.com/drone/drone) with internal certificate authority, supervisord, and custom entrypoint scripting.

[Drone](https://github.com/drone/drone) is a Continuous Delivery system built on container technology. Drone uses a simple yaml configuration file, a superset of docker-compose, to define and execute Pipelines inside Docker containers.

## Updates

Please consult [the official Ubuntu site](https://www.ubuntu.com/info/release-end-of-life) for information on when this version of Ubuntu becomes end of life.

As [Drone](https://github.com/drone/drone) is under activate development and is unstable at the current time, the version included in this image is the one which we use on our bulid system. Alternative versions can be built through build arguments.

## Usage

For documentation and demonstration purposes an example [docker-compose](https://docs.docker.com/compose/) configuration file is included which can be invoked by running `docker-compose up`. If your version of docker does not support multistage builds then you can use `make run` which will build the image and then use docker compose to run it. Note that you will need to populate various variables for the docker compose configuration to be useful. Please refer to the [documentation](https://docs.docker.com/compose/env-file/) for details.

Please note that the target production environment for this image is [OpenShift Origin](https://www.openshift.org/).

## Building and testing

**WARNING: The included Dockerfile uses the multistage feature which requires Docker version 17.05 or later**

A simple Makefile is included for your convience. It is configured not to use the multistage file so that it functions with older versions of docker. It assumes a linux environment with a docker socket available at `/var/run/docker.sock`

To build and test just run `make`.
You can also just `make pull`, `make build` and `make test` separately.

Please see the top of the Makefile for various variables which you may choose to customise. Variables may be passed as arguments, e.g. `make IMAGE_NAME=bob` or `make build BUILD_ARGS="--rm --no-cache"`

### Building an alternative version of Drone

To build a different version of drone specify the `drone_git_ref` build argument at compile time. e.g. `make COMPILE_BUILD_ARGS="--rm --build-arg drone_git_ref=v0.7.3"`

### Building without using the Makefile (docker version 17.05 or later)

The `Dockerfile` uses the multistage feature and requires Docker version 17.05 or later. This is the default file to allow for the easy use of modern tooling and automated builds through Docker Hub. This file is used by the included example docker compose configuration.

A build can be performed in the normal way:
```bash
IMAGE_NAME=ubuntu-16-drone
docker build --tag ${IMAGE_NAME} .
```

### Building without using the Makefile (without docker version 17.05 or later)

The `Dockerfile-compile` is used to produce the `drone` binary which you are then expected to copy to the `bin` sub folder of the working directory.

The `Dockerfile-container` expects the binary as described above.

The steps for using these files are:
```bash
COMPILE_IMAGE_NAME=ubuntu-16-drone-compile
IMAGE_NAME=ubuntu-16-drone

# Stage 1 Compile the drone binary
docker build COMPILE_BUILD_ARGS = --rm --tag ${COMPILE_IMAGE_NAME} --file Dockerfile-compile .

# Stage 2 - Copy the drone binary to the local work space
rm -rf bin && mkdir -p bin
CONTAINER_ID=`docker create ${COMPILE_IMAGE_NAME}`
docker cp ${CONTAINER_ID}:/go/src/github.com/drone/drone/release/drone bin
docker rm ${CONTAINER_ID}

# Stage 3 - Build the final image
docker build --tag ${IMAGE_NAME} .
```

## Modifying the tests

The tests depend on shared testing code found in its own git repository called [drone-tests](https://github.com/1and1internet/drone-tests).

To use a different tests repository set the TESTS_REPO variable to the git URL for the alternative repository. e.g. `make TESTS_REPO=https://github.com/1and1internet/drone-tests.git`

To use a locally modified copy of the tests repository set the TESTS_LOCAL variable to the absolute path of where it is located. This variable will override the TESTS_REPO variable. e.g. `make TESTS_LOCAL=/tmp/github/1and1internet/drone-tests/`
