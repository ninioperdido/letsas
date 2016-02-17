#!/bin/sh
#    LeTSAS Updater
#    This program updates a LeTSAS distro using rsync
#    from a git repo with git-fs, fuse
#
#    Copyright (C) 2013 Gerardo Puerta Cardelles <gerardo.puerta@juntadeandalucia.es>
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

## General Variables
N=$'\x1b[0;0m'
B=$'\x1b[0;01m'
R=$'\x1b[31;01m'
G=$'\x1b[00;32m'
B=$'\x1b[34;01m'

## Config Variables
USER="letsas"
HOST="10.235.85.104"
PORT="873"
PROTO="rsync"
REPO="letsas"
BRANCH="testing"
AREA="latest"
CMDLINE="/var/tmp/cmdline"
FILTER="LETSAS"
UPATH="/"
OPTS="-rahc --inplace --del --stats -x --chown=root:root"
#OPTS="-rlO --size-only"
RSYNC="/usr/bin/rsync"
CAT="/bin/cat"
EXPR="/bin/expr"
DEBUG="True"
LEGACY_CHECK="/usr/bin/slim"
EXCLUDE=" --exclude-from /etc/rsync_excludes.conf"
# Variable processing
# Check all the params against filter if then
# extract subvariable from filter_something
# and its value
filter() {
	until [ -z "$1" ]
	do
		if [ `${EXPR} "${1}" : "${FILTER}.*="` != 0 ]
		then
		   LA=${1%%=*}
		   LA=${LA##*_}
		   eval $LA=${1##*=}
		fi
		shift
	done
}

## Check for superuser access
if [ $UID ] && [ "$UID" -ne  0 ]
then
    echo "Error! You are not a superuser."
	exit 1
fi

## Setting parameters
if [ -f "$CMDLINE" ]
then
  filter `${CAT} ${CMDLINE}`
fi

## Area needs _ before 
## due to git subranch nest limitation

if [ "${AREA}" != '' ]
then
 	AREA="${AREA}/"
fi

#if [ "${AREA}" == '' -a "${BRANCH}" != "" ]
if [ "${BRANCH}" != "" ]
then
    BRANCH="${BRANCH}/"
fi

if [ "${USER}" != '' ]
then
 	USER="${USER}@"
fi

# Updating legacy LeTSAS
if [ ! -f "$LEGACY_CHECK" ]
then
  #echo "_display_busy=0; while(1){next; sleep '1';};" | /usr/bin/fim -qp /usr/share/slim/themes/default/loading*.jpg &
  FIRST_UPGRADE=1
fi

if [ "$DEBUG" == "True" ]
then
	echo "${RSYNC} ${OPTS} ${EXCLUDE} ${PROTO}://${USER}${HOST}/${REPO}/${BRANCH}${AREA} ${UPATH} --port=${PORT}"
fi

${RSYNC} ${OPTS} ${EXCLUDE} ${PROTO}://${USER}${HOST}/${REPO}/${BRANCH}${AREA} ${UPATH} --port=${PORT}

if [ "$FIRST_UPGRADE" == "1" ]
then
    reboot
fi

