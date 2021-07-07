# Add support for ##TODO add names of support modules##
ARG REGISTRY=ghcr.io/epics-containers
ARG ADCORE_VERSION=3.10r2.0

FROM ${REGISTRY}/epics-areadetector:${ADCORE_VERSION}

# install additional tools and libs
USER root

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ## TODO replace busybox with any required libraries/tools ##
    busybox-static \
    && rm -rf /var/lib/apt/lists/*


USER ${USERNAME}

# get additional support modules
## TODO replace examples with support module version numbers ##
# ARG ADARAVIS_VERSION=R2-2-1
# ARG ADGENICAM_VERSION=R1-8

## TODO replace examples with support module source locations ##
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
RUN make -j -C  ${SUPPORT}/ADGenICam-${ADGENICAM_VERSION} && \
    make -j -C  ${SUPPORT}/ADAravis-${ADARAVIS_VERSION} && \
    make -j -C  ${EPICS_ROOT}/ioc && \
    make -j clean

