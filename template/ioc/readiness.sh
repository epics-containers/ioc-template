#!/bin/bash
# Readiness probe for IOC instances.
#
# The IOC is Ready once its liveness PV answers over Channel Access. This
# stops a pod that crashes during startup (e.g. its device is powered off)
# from briefly reporting Ready on every restart, which makes the StatefulSet
# replica alerts resolve and re-fire on each crash loop.
#
# Enable it in the ioc-instance values, for example:
#   readinessExecutable: /epics/ioc/readiness.sh
# or, to require the PV to stay up for several checks before Ready:
#   readinessProbe:
#     exec:
#       command: [/bin/bash, /epics/ioc/readiness.sh]
#     periodSeconds: 10
#     successThreshold: 3

TOP=/epics/ioc
cd ${TOP} || exit 1

CONFIG_DIR=${TOP}/config
THIS_SCRIPT=$(realpath ${0})
override=${CONFIG_DIR}/readiness.sh

if [[ -f ${override} && ${override} != "${THIS_SCRIPT}" ]]; then
    exec bash ${override}
fi

# use the same PV and CA settings as liveness.sh, including their overrides
K8S_IOC_PV=${K8S_IOC_PV:-"${IOC_PREFIX^^}:UPTIME"}
K8S_IOC_PORT=${K8S_IOC_PORT:-5064}

export EPICS_CA_ADDR_LIST=${K8S_IOC_ADDRESS}
export EPICS_CA_SERVER_PORT=${K8S_IOC_PORT}

# not ready is the normal state while the IOC starts, so unlike liveness.sh
# this does not write to the IOC's log on failure
caget ${K8S_IOC_PV} > /dev/null 2>&1
