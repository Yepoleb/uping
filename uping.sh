#!/usr/bin/env bash
# Copyright (C) 2014 Jonas Friedmann - License: WTFPL

###
# Settings
###

BIN_PING="ping"

###
# Functions
###

function usage() {
    cat << EOUSAGE
Usage: ${0} [hostname] <option>

OPTIONS
    -debug          Enable debug output
EOUSAGE
}

# Function to determine if the host is online
function check_reachability(){
    if ! ping -c 1 -t 1 ${1} &> /dev/null; then
        echo "The host \"${1}\" seems to be unreachable"
        echo -ne "Waiting for host to come back: "
        START=$(date +%s.%N)
        ping_host ${1}
    else
        echo "The host \"${1}\" seems to be reachable"
    fi
}

# Function to continuously ping until its back
function ping_host() {
    if ! ping -c 1 -t 1 ${1} &> /dev/null; then
        echo -ne "."
        sleep 1
        ping_host ${1}
    else
        END=$(date +%s.%N) && DIFF=$(echo "$END - $START" | bc)
        echo -ne "\nThe host \"${1}\" seems to be reachable again, took ${DIFF} ms"
    fi
}

###
# DO NOT EDIT BELOW
###

# Check for -debug argument
echo "$@" > /dev/null 2>&1
if [ "$_" = '-debug' ]; then
    set -x
fi

# Check if binaries exist
BINS=( "${BIN_PING}" )
for BIN in $BINS; do
  type -P $BIN &>/dev/null && continue || echo "'$BIN not found! Run 'apt-get/brew install $BIN' to fix this"; exit 1
done

# Check for arguments
if [ ${#} -eq 0 ]; then
    usage
    exit 1
fi

check_reachability ${1}

exit 0
