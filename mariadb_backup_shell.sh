#!/bin/bash
BACKUP_IP=192_168_1_57
BACKUP_TYPE=db_mariadb
BACKUP_DATE="`date '+%Y%m%d'`"
BACKUP_NAME=${BACKUP_DATE}${BACKUP_TYPE}${BACKUP_IP}.tar.gz
BACKUP_ROOT_PATH=/home/backup
BACKUP_ERROR_PATH=${BACKUP_ROOT_PATH}/err
BACKUP_PATH=${BACKUP_ROOT_PATH}/${BACKUP_TYPE}

DB_INFO_FILE=${BACKUP_ROOT_PATH}/conf/db_info.sh
REMOTE_INFO_FILE=${BACKUP_ROOT_PATH}/conf/remote_info.sh

if [ ! -e ${DB_INFO_FILE} ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    echo "db info file dose not exist." >> ${BACKUP_ERROR_PATH}/${BACKUP_DATE}`date '+%Y%m%d$H$M$S'`_error.txt
    exit 1
else
    #db_info File include
    source ${DB_INFO_FILE}
fi

if [ ! -e ${REMOTE_INFO_FILE} ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    echo "remote info file dose not exist." >> ${BACKUP_ERROR_PATH}/${BACKUP_DATE}_error.txt
    exit 1
else
    #remote_info File include
    source ${REMOTE_INFO_FILE}
    REMOTE_PATH=/backup/${BACKUP_TYPE}/${BACKUP_IP}
fi

if [ ! -d ${BACKUP_PATH} ];then
    mkdir -p ${BACKUP_PATH}
fi

if [ ! `which mariadb` ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    echo "mariadb dose not installed" >> ${BACKUP_ERROR_PATH}/${BACKUP_DATE}_error.txt
    exit 1
else
    db_list=`echo "show databases;" | mysql -N -uroot -p "${DB_PASSWORD}"`

    for db in $db_list ;do
        table_list=`echo "show tables" | mysql -N -uroot -p "${DB_PASSWORD}" $db`
	for table in $table_list ;do
            mysqldump -uroot -p "${DB_PASSWORD}" $db $table > $db_$table.sql
	done
    done
fi
