FROM ubuntu:latest

ADD . /usr/src/app
ADD ./netrc /root/.netrc
WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get -y install python-pip python-dev git libxml2-dev libxslt1-dev cmake vim jq && \
    pip2 install --no-cache-dir --upgrade pip && \
    pip2 install virtualenv


# Checkout git repos for build and test
RUN ./setup.sh

#CMD ["./run_tests_from_docker.sh"]
