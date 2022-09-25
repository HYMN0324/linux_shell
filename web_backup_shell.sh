#!/bin/bash

############################
# WRITER      : hyomin     #
# WRITE_DATE  : 2022-08-20 #
# UPDATE_DATE : 2022-09-09 #
# CONTENT     : WEB BACKUP #
############################

EXECUTE_DATE="`date '+%Y-%m-%d'`"
EXECUTE_DATE_TIME=" `date '+%Y-%m-%d %H:%M:%S'`"
BACKUP_TYPE=web
BACKUP_CONF_FILE=/home/backup/conf/backup_conf.sh
BACKUP_TEMP_ERROR_FILE=/home/backup/log/${EXECUTE_DATE}_error.txt

if [ ! -e ${BACKUP_CONF_FILE} ];then
    echo "backup conf file dose not exist.[ERROR 1000] ${EXECUTE_DATE_TIME}" >> ${BACKUP_TEMP_ERROR_FILE}
    exit 1
else
    # backup conf file include
    source ${BACKUP_CONF_FILE}
fi

if [ ! -d ${WEB_SOURCE_PATH} ];then
    fn_error_log "source directory dose not exist.[ERROR 2000] ${EXECUTE_DATE_TIME}"
    exit 1
else
    cd ${WEB_SOURCE_PATH}

    #web dir create to archive file
    web_dir_list=`ls -d */ | sed s,/,,`
    #web file copy(exclude archive file)
    web_file_list=`find ./ -maxdepth 1 -type f | sed 's/^\.\///g'`

    if [ ! -d ${BACKUP_PATH} ];then
        mkdir -p ${BACKUP_PATH}
    fi
    cd ${BACKUP_PATH}

    for web_dir in $web_dir_list;do
        tar -zcf $web_dir.tar.gz ${WEB_SOURCE_PATH}/$web_dir
        wait
    done

    for web_file in $web_file_list;do
        cp -apf ${WEB_SOURCE_PATH}/$web_file ./$web_file
    done

    cd ../

    tar -zcf ${BACKUP_FILE_NAME} ${BACKUP_PATH}
    wait

    rm -rf ${BACKUP_DATE}
fi

expect << EOF
    spawn sudo rsync ${BACKUP_FILE_NAME} ${DEST_USER}@${DEST_IP}:${DEST_PATH}
    expect "password:"
    sleep 0.2
    send "${DEST_PW}\n"
    expect eof
EOF

exit 0
