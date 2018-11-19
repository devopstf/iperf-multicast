#!/bin/bash
# Script to start iperf in client or server mode

set -euo pipefail
IFS=$'\n\t'

# environment variables read on startup:
#
# Run in the client or server role
# ROLE = [client || server]
#
# The remote IP of the server to connect to in client role
# SERVER_ADDR = [ip || host]
#
# iperf itself responds to a a number of environment variables that
# can be used to configure the way it behaves in client and server
# mode. See the iperf documentation for a more complete list.
#
# https://iperf.fr/iperf-doc.php
#

# initialize from environment
role=${ROLE:-}
role_arg=
server_addr=${SERVER_ADDR:-127.0.0.1}
ttl=${TTL:-2}
time=${TIME:-10}
window=${WINDOW:-8K}
bandwidth=${BANDWIDTH:-100K}
udp=${UDP:-u}
length=${LENGTH:-200K}

# set up for running as the client or server
if [ "${role}" = "client" ]; then
    if [ -z "${server_addr}" ]; then
        server_addr=127.0.0.1
    fi
    role_arg="-c"
elif [ "${role}" = "server" ]; then
    server_addr=
    role_arg="-s"
else
    echo "Error: unknown ROLE: ${role}"
    exit 1
fi

# start iperf
exec iperf -${udp} ${role_arg} ${server_addr} --ttl ${ttl} -l ${length} -w ${window} -b ${bandwidth}