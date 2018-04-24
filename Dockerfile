FROM maven:3.5.3-jdk-8-alpine

# VERSIONS to pull
ENV PYTHON_VERSION 3.6.3-r9
ENV ALPINE_OLD_VERSION 3.7

# most needed only
ENV OSPKGS "ca-certificates curl git cmake gcc make alpine-sdk"
# as per code
ENV PYPKGS "newrelic"

# Hack: using older alpine version to install specific python version
RUN sed -n \
    's|^http://dl-cdn\.alpinelinux.org/alpine/v\([0-9]\+\.[0-9]\+\)/main$|\1|p' \
    /etc/apk/repositories > curr_version.tmp && \
    sed -i 's|'$(cat curr_version.tmp)'/main|'$ALPINE_OLD_VERSION'/main|' \
    /etc/apk/repositories
# Installing given python3 version and others
RUN apk update && \
    apk add ${OSPKGS} && \
    apk add python3=$PYTHON_VERSION
# clean alpine apk cache
RUN rm -rf /var/cache/apk/*
# add python & pip
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/pip3 /usr/bin/pip
# Upgrading pip to the last compatible version
RUN pip3 install --upgrade pip
# Installing IPython & other libs
RUN pip install ${PYPKGS}
# Reverting hack
RUN sed -i 's|'$(cat curr_version.tmp)'/main|'$ALPINE_OLD_VERSION'/main|' \
    /etc/apk/repositories && \
    rm curr_version.tmp
# you are done creating the image
