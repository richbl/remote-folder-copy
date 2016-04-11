#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# -----------------------------------------------------------------------------
# Copyright (C) Business Learning Incorporated (businesslearninginc.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
# -----------------------------------------------------------------------------
#
# A bash script to remotely copy a folder using scp
#
# version: 0.3.0
#
# requirements:
#
#  --sshpass command installed
#  --jq (json query) command installed
#
# inputs:
#
#  --username
#  --user password
#  --website/server (domain name) to access
#  --folder source location
#  --folder destination location
#
# outputs:
#
#  --notification of success/failure
#  --side-effect: moved folder
#

# -----------------------------------------------------------------------------
# script configuration
#
shopt -s extglob
EXEC_DIR="$(dirname "$0")"

. ${EXEC_DIR}/lib/args

ARGS_FILE="${EXEC_DIR}/data/config.json"
declare -A ARGS
declare -a REQ_PROGRAMS=('sshpass' 'jq')

# -----------------------------------------------------------------------------
# check script dependencies and set vars
#
check_dependencies "REQ_PROGRAMS[@]"
COUNT_ARGS=$(jq '.arguments | length'< ${ARGS_FILE})

# -----------------------------------------------------------------------------
# perform script configuration, arguments parsing, and validation
#
load_args_file
display_banner
scan_for_args "$@"
check_for_args_completeness

# -----------------------------------------------------------------------------
# template assignments to make remaining code easier to read (optional)
#
ARG_username=${ARGS[1,0]}
ARG_password=${ARGS[2,0]}
ARG_website=${ARGS[3,0]}
ARG_port=${ARGS[4,0]}
ARG_source=${ARGS[5,0]}
ARG_destination=${ARGS[6,0]}

# -----------------------------------------------------------------------------
# perform remote folder copy
#
echo "Copying remote folder..."
echo

# dump to /tmp first to catch sshpass errors
#
sshpass -p "${ARG_password}" scp -r -P "${ARG_port:-22}" "${ARG_username}"@"${ARG_website}":"${ARG_source}" "/tmp" &>/dev/null;
RETURN_CODE=$?

if [ ${RETURN_CODE} -ne 0 ]; then
  rm -rf "/tmp/${ARG_source##*/}"
  echo "Error: sshpass return code ${RETURN_CODE} encountered (see http://linux.die.net/man/1/sshpass for details)."
  echo "Remote folder copy failed."
  quit
else

  if [ "${ARG_COMPRESSION}" == "true" ]; then
    ARCHIVE="${ARG_website}"-"${ARG_source##*/}"-"$(date +"%Y%m%d%H%M%S")".tar.gz
    tar -zcf "${ARG_destination}/${ARCHIVE}" -C /tmp "${ARG_source##*/}"
  else
    mv "/tmp/${ARG_source##*/}" "${ARG_destination}" &>/dev/null;
  fi

  echo "Success."
  echo "Remote folder ${ARG_website}:${ARG_source} copied to ${ARG_destination}/"${ARG_source##*/}"."
  echo
fi
