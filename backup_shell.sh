#!/bin/bash
BACKUP_IP=192_168_1_57
BACKUP_TYPE=web
BACKUP_DATE="`date '+%Y%m%d'`"
BACKUP_NAME=${BACKUP_DATE}${BACKUP_TYPE}${BACKUP_IP}.tar.gz
BACKUP_ROOT_PATH=/home/backup
BACKUP_TEMP_PATH=${BACKUP_ROOT_PATH}/temp
BACKUP_ERROR_PATH=${BACKUP_ROOT_PATH}/err
BACKUP_PATH=${BACKUP_ROOT_PATH}/${BACKUP_TYPE}

REMOTE_INFO_FILE=${BACKUP_ROOT_PATH}/conf/remote_info.txt

SOURCE_PATH=/home/nessystem/nesweb/htdocs

if [ ! -e ${REMOTE_INFO_FILE} ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    echo "remote info file dose not exist." >> ${BACKUP_ERROR_PATH}/${BACKUP_DATE}_error.txt
    exit 1
else
    REMOTE_IP=grep | awk '{print $1}' ${REMOTE_INFO_FILE}
    REMOTE_USER=grep | awk '{print $2}' ${REMOTE_INFO_FILE}
    REMOTE_PW=grep | awk '{print $3}' ${REMOTE_INFO_FILE}
    REMOTE_PATH=/backup/${BACKUP_TYPE}/${BACKUP_IP}
fi

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
