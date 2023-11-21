#!/bin/bash

LDIR=./
RHOST=allquantor.at
RDIR=/var/www/sape/jupyter/
PUBLISH=./publish.txt

rsync --files-from=${PUBLISH} -avz --recursive --sparse -e "ssh" --log-file=./rsync_remote_`date -Is`.log --progress ${LDIR} ${RHOST}:"${RDIR}"
