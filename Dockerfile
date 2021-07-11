############################################################################
## EXAMPLE TEMPLATE for generic IOC container image build file            ##
##                                                                        ##
## Search for 'TODO' in this file and perform the documented actions      ##
## TODO - replace this header with a desccription of the support modules  ##
##    you are adding in this build                                        ##
############################################################################

## TODO change this to the registry that the base image resides in
ARG REGISTRY=ghcr.io/epics-containers
## TODO replace below with base image version you want to use
ARG ADCORE_VERSION=3.10r3.0

## TODO replace these examples with the new support module(s) version number(s) ##
ARG ADARAVIS_VERSION=R2-2-1
ARG ADGENICAM_VERSION=R1-8

##### runtime stage ############################################################

## TODO replace below with base image tag you want to use
FROM ${REGISTRY}/epics-areadetector:${ADCORE_VERSION} AS developer

## TODO declare global args for reuse in this build stage
ARG ADARAVIS_VERSION
ARG ADGENICAM_VERSION

# install additional tools and libs
USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ## TODO replace busybox with any required libraries/tools ##
    busybox-static \
    && rm -rf /var/lib/apt/lists/*

## TODO add any manual compilation or installation of tools or libraries here

USER ${USERNAME}

# get additional support modules

## TODO replace examples with support module(s) source locations ##
# RUN python3 module.py add areaDetector ADGenICam ADGENICAM ${ADGENICAM_VERSION}
# RUN python3 module.py add areaDetector ADAravis ADARAVIS ${ADARAVIS_VERSION}

# add CONFIG_SITE.linux and RELEASE.local
## TODO create configure folder in context to make modules compatible with ubuntu  ##
## TODO replace examples with support module configure folders ##
# COPY --chown=${USER_UID}:${USER_GID} configure ${SUPPORT}/ADGenICam-${ADGENICAM_VERSION}/configure
# COPY --chown=${USER_UID}:${USER_GID} configure ${SUPPORT}/ADAravis-${ADARAVIS_VERSION}/configure

# update the generic IOC Makefile to include the new support
## TODO Update Makefile in context as required
COPY --chown=${USER_UID}:${USER_GID} Makefile ${EPICS_ROOT}/ioc/iocApp/src

# update dependencies and build the support modules and the ioc
RUN python3 module.py dependencies
## TODO replace examples with support module(s)
RUN \
    # make -j -C  ${SUPPORT}/ADGenICam-${ADGENICAM_VERSION} && \
    # make -j -C  ${SUPPORT}/ADAravis-${ADARAVIS_VERSION} && \
    make -j -C  ${IOC} && \
    make -j clean


##### runtime stage ############################################################

FROM ${REGISTRY}/epics-areadetector:${ADCORE_VERSION}.run AS runtime

## TODO declare global args for reuse in this build stage
ARG ADARAVIS_VERSION
ARG ADGENICAM_VERSION

# install runtime libraries from additional packages section above
USER root

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ## TODO replace busybox with any required RUNTIME libraries/tools ##
    busybox-static \
    && rm -rf /var/lib/apt/lists/*

## TODO copy any manually built RUNTIME files
# COPY --from=developer /usr/lib/librdkafka* /usr/lib/

USER ${USERNAME}

## TODO add COPYs of the built module folders below
# get the products from the build stage
# COPY --from=developer --chown=${USER_UID}:${USER_GID} ${SUPPORT}/ADGenICam-${ADGENICAM_VERSION} ${SUPPORT}/ADGenICam-${ADGENICAM_VERSION}
# COPY --from=developer --chown=${USER_UID}:${USER_GID} ${SUPPORT}/ADAravis-${ADARAVIS_VERSION} ${SUPPORT}/ADAravis-${ADARAVIS_VERSION}
COPY --from=developer --chown=${USER_UID}:${USER_GID} ${IOC} ${IOC}