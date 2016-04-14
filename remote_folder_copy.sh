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
# version: 0.4.0
#
# requirements:
#  --sshpass command installed
#  --jq (json query) command installed
#
# inputs:
#  --username
#  --user password
#  --website/server (domain name) to access
#  --folder source location
#  --folder destination location
#
# outputs:
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

# [user-config] set any external program dependencies here
declare -a REQ_PROGRAMS=('jq')

# -----------------------------------------------------------------------------
# perform script configuration, arguments parsing, and validation
#
check_program_dependencies "REQ_PROGRAMS[@]"
display_banner
scan_for_args "$@"
check_for_args_completeness

# -----------------------------------------------------------------------------
# perform remote folder copy
#
echo "Copying remote folder..."
echo

# dump to /tmp first to catch sshpass errors
#
ARG_PORT=$(get_config_arg_value port)
sshpass -p "$(get_config_arg_value password)" scp -r -P "${ARG_PORT:-22}" "$(get_config_arg_value username)"@"$(get_config_arg_value website)":"$(get_config_arg_value source)" "/tmp" &>/dev/null;
RETURN_CODE=$?

if [ ${RETURN_CODE} -ne 0 ]; then
  rm -rf "/tmp/$(basename $(get_config_arg_value source))"
  echo "Error: sshpass return code ${RETURN_CODE} encountered (see http://linux.die.net/man/1/sshpass for details)."
  echo "Remote folder copy failed."
  quit
else
  if [ "$(get_config_details compress_results)" == "true" ]; then
    ARCHIVE="$(get_config_arg_value website)"-"$(basename $(get_config_arg_value source))"-"$(date +"%Y%m%d%H%M%S")".tar.gz
    tar -zcf "$(get_config_arg_value destination)/${ARCHIVE}" -C /tmp "$(basename $(get_config_arg_value source))"
  else
    mv "/tmp/$(basename $(get_config_arg_value source))" "$(get_config_arg_value destination)" &>/dev/null;
  fi

  echo "Success."
  echo "Remote folder $(get_config_arg_value website):$(get_config_arg_value source) copied to $(get_config_arg_value destination)/"$(basename $(get_config_arg_value source))"."
  echo
fi
