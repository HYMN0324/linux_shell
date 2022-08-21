#!/bin/bash
BACKUP_IP=192_168_1_57
BACKUP_TYPE=web
BACKUP_DATE="`date '+%Y%m%d'`"
BACKUP_NAME=${BACKUP_DATE}${BACKUP_TYPE}${BACKUP_IP}.tar.gz
BACKUP_ROOT_PATH=/home/backup
BACKUP_ERROR_PATH=${BACKUP_ROOT_PATH}/err
BACKUP_PATH=${BACKUP_ROOT_PATH}/${BACKUP_TYPE}

REMOTE_INFO_FILE=${BACKUP_ROOT_PATH}/conf/remote_info.sh

SOURCE_PATH=/home/nessystem/nesweb/htdocs

if [ ! -e ${REMOTE_INFO_FILE} ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    echo "remote info file dose not exist." >> ${BACKUP_ERROR_PATH}/${BACKUP_DATE}_error.txt
    exit 1
else
    source ${REMOTE_INFO_FILE} #File include
    REMOTE_PATH=/backup/${BACKUP_TYPE}/${BACKUP_IP}
fi

if [ ! -d ${BACKUP_PATH} ];then
    mkdir -p ${BACKUP_PATH}
fi
if [ ! -d ${SOURCE_PATH} ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    echo "source directory dose not exist." >> ${BACKUP_ERROR_PATH}/${BACKUP_DATE}_error.txt
    exit 1
else
    cd ${BACKUP_PATH}
    tar -zcf ${BACKUP_NAME} ${SOURCE_PATH}
    wait
fi

expect << EOF
    spawn sudo rsync ${BACKUP_PATH}/${BACKUP_NAME} ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_PATH}
    expect "password:"
    sleep 0.2
    send "${REMOTE_PW}\n"
expect eof
EOF
wait
