PWD = $(shell pwd)
IMAGE_NAME = $(shell basename ${PWD})
BASE_IMAGE = $(shell grep Dockerfile -e FROM | cut -d ' ' -f 2)
RSPEC_IMAGE = 1and1internet/ubuntu-16-rspec
TESTS_REPO = https://github.com/1and1internet/drone-tests.git
DOCKER_SOCKET = /var/run/docker.sock
BUILD_ARGS = --rm
COMPILE_IMAGE_NAME = ${IMAGE_NAME}-compile
COMPILE_BUILD_ARGS = --rm
RSPEC_ARGS = 

# To use a locally modified copy of the tests repository set the TESTS_LOCAL variable to the absolute path of where it is located.
TESTS_LOCAL =

# This path is hard coded in Dockerfile-container - do not override
BIN_PATH = ${PWD}/bin/

all: pull build test

pull:
	##
	## Pulling image updates from registry
	##
	for IMAGE in ${BASE_IMAGE} ${RSPEC_IMAGE}; \
		do docker pull $${IMAGE}; \
	done

build: build-binary build-image

build-multistage:
	##
	## Starting build of image ${IMAGE_NAME} using multistage build (Docker > 17.05)
	##
	docker build ${BUILD_ARGS} --tag ${IMAGE_NAME} --file Dockerfile .

build-binary:
	##
	## Starting build of image ${COMPILE_IMAGE_NAME}
	##
	rm -rf ${BIN_PATH} && mkdir -p ${BIN_PATH}
	docker build ${COMPILE_BUILD_ARGS} --tag ${COMPILE_IMAGE_NAME} --file Dockerfile-compile .
	$(eval CONTAINER_ID = $(shell docker create ${COMPILE_IMAGE_NAME}))
	docker cp ${CONTAINER_ID}:/go/src/github.com/drone/drone/release/drone ${BIN_PATH}
	docker rm -v ${CONTAINER_ID}

build-image:
	##
	## Starting build of image ${IMAGE_NAME}
	##
	docker build ${BUILD_ARGS} --tag ${IMAGE_NAME} --file Dockerfile-container .

test:
	##
	## Starting tests inside a new container running ${RSPEC_IMAGE}
ifdef TESTS_LOCAL
	##  with tests from ${TESTS_LOCAL}
	##
	docker run --rm -i -t -v ${DOCKER_SOCKET}:/var/run/docker.sock -v ${PWD}/:/mnt/ -v ${TESTS_LOCAL}/:/drone-tests/ ${RSPEC_IMAGE} make run-rspec IMAGE_NAME=${IMAGE_NAME}
else
	##  with tests from ${TESTS_REPO}
	##
	docker run --rm -i -t -v ${DOCKER_SOCKET}:/var/run/docker.sock -v ${PWD}/:/mnt/ ${RSPEC_IMAGE} make do-test IMAGE_NAME=${IMAGE_NAME}
endif

do-test: checkout-drone-tests run-rspec

checkout-drone-tests:
	mkdir ../drone-tests
	git clone ${TESTS_REPO} ../drone-tests

run-rspec:
	## Testing image ${IMAGE_NAME}
	IMAGE=${IMAGE_NAME} rspec ${RSPEC_ARGS}

run:
	##
	## Running with docker compose
	###
	docker-compose up

clean:
	docker rmi ${IMAGE_NAME}
	docker rmi ${COMPILE_IMAGE_NAME}
	rm -rf ${BIN_PATH}

.PHONY: all pull build build-binary build-image build-multistage test do-test checkout-drone-tests run-rspec run clean
