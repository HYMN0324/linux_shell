#!/bin/bash

############################
# WRITER      : hyomin     #
# WRITE_DATE  : 2022-08-20 #
# UPDATE_DATE : 2022-09-09 #
# CONTENT     : WEB BACKUP #
############################

EXECUTE_DATE="`date '+%Y-%m-%d'`"
EXECUTE_DATE_TIME=" `date '+%Y-%m-%d %H:%M:%S'`"
BACKUP_CONF_FILE=/home/backup/conf/backup_conf.sh
BACKUP_TEMP_ERROR_FILE=/home/backup/log/${EXECUTE_DATE}_error.txt

if [ ! -e ${BACKUP_CONF_FILE} ];then
    echo "backup conf file dose not exist.[ERROR 1000] ${EXECUTE_DATE_TIME}" >> ${BACKUP_TEMP_ERROR_FILE}
    exit 1000
else
    # backup conf file include
    source ${BACKUP_CONF_FILE}
fi

if [ ! -d ${WEB_SOURCE_PATH} ];then
    fn_error_log "source directory dose not exist.[ERROR 2000] ${EXECUTE_DATE_TIME}"
    exit 2000
else
    if [ ! -d ${BACKUP_PATH} ];then
        mkdir -p ${BACKUP_PATH}
    fi

    cd ${BACKUP_PATH}
    tar -zcf ${BACKUP_FILE_NAME} ${SOURCE_PATH}
    wait
fi

expect << EOF
    spawn sudo rsync ${BACKUP_PATH}/${BACKUP_FILE_NAME} ${DEST_USER}@${DEST_IP}:${DEST_PATH}
    expect "password:"
    sleep 0.2
    send "${DEST_PW}\n"
expect eof
EOF

exit 0
