#!/bin/bash
# Script to be called by .gitlab-ci.yml before it starts an IOC from tests/config.
#
# The job's pod runs on a site cluster, where an IOC could reach real hardware,
# so only the generic test config from ioc-template may start there: soft records
# and iocStats, no devices. Fail with an explanation if tests/config holds
# anything else. To keep extra IOC configs in a repo, put them outside tests/config.

allowed="devIocStats.iocAdminSoft epics.EpicsEnvSet epics.PostStartupCommand epics.StartupCommand epics.dbpf"

cd "$(dirname "$0")/../tests/config" || {
    echo "ERROR: there is no tests/config folder"
    exit 1
}

status=0

files=$(ls -A | tr '\n' ' ')
if [[ ${files} != "ioc.db ioc.yaml " ]]; then
    echo "ERROR: tests/config must hold only ioc.db and ioc.yaml, found: ${files}"
    status=1
fi

types=$(sed -n 's/^[ -]*type:[ ]*//p' ioc.yaml 2>/dev/null | tr -d '"'\' | sort -u)
for type in ${types}; do
    if [[ " ${allowed} " != *" ${type} "* ]]; then
        echo "ERROR: tests/config/ioc.yaml uses ${type}: only ${allowed} may start in CI"
        status=1
    fi
done

if grep -Enr '([0-9]{1,3}\.){3}[0-9]{1,3}' . ; then
    echo "ERROR: tests/config names an IP address, see above"
    status=1
fi

exit ${status}
