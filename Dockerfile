########################################################################################################################
## -- first we build and run the generator, which is responsible for producing all the source packages,
##    for all java versions, for all OS's (debian/ubuntu) and for all distribuitions (xenial/trusty/jessie/etc)
FROM node:10-alpine as generator

# First, only package.json and lockfile, so we docker-layer-cache npm dependencies.
ADD generator/package*.json /gen/generator/
WORKDIR /gen/generator
RUN npm install

# Then the rest of the generator app and the templates...
ADD generator/generate.js /gen/generator/generate.js
ADD templates /gen/templates
# ... and then run the generator.
RUN node generate.js
RUN ls -laR /gen/generated/debian


########################################################################################################################
## -- Now its the Ubuntu package builder's turn.
##    We use bionic here, but supposedly any could be used,
##    since the packages are so simple.
FROM ubuntu:bionic as ubuntuBuilder
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
# build-time dependencies
RUN apt-get -y --no-install-recommends install devscripts build-essential lintian debhelper fakeroot lsb-release figlet
# install-time dependencies (those are listed in Depends or Pre-Depends in debian/control file)
RUN apt-get -y --no-install-recommends install java-common wget locales ca-certificates
WORKDIR /opt/amazoncorretto/ubuntu
COPY --from=generator /gen/generated/ubuntu /opt/amazoncorretto/ubuntu
RUN ls -laR /opt/amazoncorretto/ubuntu
ADD docker/build_packages_multi.sh /opt/amazoncorretto/
# those will be populated by the build script.
RUN mkdir -p /binaries /sourcepkg
RUN /opt/amazoncorretto/build_packages_multi.sh ubuntu


########################################################################################################################
## -- Now its the Debian package builder's turn.
##    We use jessie here, but supposedly any could be used,
##    since the packages are so simple.
FROM debian:jessie as debianBuilder
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
# build-time dependencies
RUN apt-get -y --no-install-recommends install devscripts build-essential lintian debhelper fakeroot lsb-release figlet
# install-time dependencies (those are listed in Depends or Pre-Depends in debian/control file)
RUN apt-get -y --no-install-recommends install java-common wget locales ca-certificates
# install-test dependencies
RUN apt-get -y --no-install-recommends install libxrender1 libxtst6 libxi6 libfontconfig1 libasound2
WORKDIR /opt/amazoncorretto/debian
COPY --from=generator /gen/generated/debian /opt/amazoncorretto/debian
ADD docker/build_packages_multi.sh /opt/amazoncorretto/
# those will be populated by the build script.
RUN mkdir -p /binaries /sourcepkg
RUN /opt/amazoncorretto/build_packages_multi.sh debian


########################################################################################################################
## -- the final image produced from this Dockerfile just contains the produced source and binary packages.
##    it uses alpine:3.8 because that's light enough, and already downloaded for node:10-alpine
FROM alpine:3.8

COPY --from=ubuntuBuilder /sourcepkg/* /sourcepkg/
COPY --from=debianBuilder /binaries/* /binaries/

# Hack: use volumes to "exfiltrate" the source files back to the host machine.
# This is just a marker directory to avoid mistakes when mounting volumes.
RUN mkdir -p /exfiltrate_to/empty

# Simple script to exfiltrate on run.
COPY docker/exfiltrate.sh /opt/exfiltrate.sh
CMD /opt/exfiltrate.sh
