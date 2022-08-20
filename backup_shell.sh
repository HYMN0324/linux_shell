#!/bin/bash
LOCAL_IP=192_168_1_57
BACKUP_TYPE=web
BACKUP_DATE="`date '+%Y%m%d'`"
BACKUP_NAME=${BACKUP_DATE}${BACKUP_TYPE}${LOCAL_IP}.tar.gz
BACKUP_TEMP_PATH=/home/backup/temp
BACKUP_PATH=/home/backup/${BACKUP_TYPE}
SOURCE_PATH=/home/nessystem/nesweb/htdocs

REMOTE_IP=awk '{ print $0 }' remote_info.txt
REMOTE_USER=awk '{ print $1 }' remote_info.txt
REMOTE_PW=awk '{ print $2 }' remote_info.txt
REMOTE_PATH=/backup/${BACKUP_TYPE}/${LOCAL_IP}

if [ ! -d ${BACKUP_TEMP_PATH} ];then
    mkdir -p ${BACKUP_TEMP_PATH}
fi

if [ ! -d ${BACKUP_PATH} ];then
    mkdir -p ${BACKUP_PATH}
fi

cp -arp ${SOURCE_PATH}/* ${BACKUP_TEMP_PATH}
wait
cd ${BACKUP_PATH}
tar -zcf ${BACKUP_NAME} ${BACKUP_TEMP_PATH}
wait
expect << EOF
  spawn sudo rsync ${BACKUP_PATH}/${BACKUP_NAME} ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_PATH}
  expect "password:"
  sleep 0.2
  send "${REMOTE_PW}\n"
expect eof
EOF
wait
rm -rf ${BACKUP_TEMP_PATH}
