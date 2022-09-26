#!/bin/bash
  
################################
# WRITER      : hyomin         #
# WRITE_DATE  : 2022-08-20     #
# UPDATE_DATE : 2022-09-25     #
# CONTENT     : MariaDB BACKUP #
################################

EXECUTE_DATE="`date '+%Y-%m-%d'`"
EXECUTE_DATE_TIME=" `date '+%Y-%m-%d %H:%M:%S'`"
BACKUP_TYPE=mariadb
BACKUP_CONF_FILE=/home/backup/conf/backup_conf.sh
BACKUP_TEMP_ERROR_FILE=/home/backup/log/${EXECUTE_DATE}_error.txt

if [ ! -e ${BACKUP_CONF_FILE} ];then
    echo "backup conf file dose not exist.[ERROR 1010] ${EXECUTE_DATE_TIME}" >> ${BACKUP_TEMP_ERROR_FILE}
    exit 1
else
    # backup conf file include
    source ${BACKUP_CONF_FILE}
fi

if [ ! command -v mariadb &> /dev/null ];then
    if [ ! -d ${BACKUP_ERROR_PATH} ];then
        mkdir -p ${BACKUP_ERROR_PATH}
    fi
    #fn_error_log "mariadb is not installed.[ERROR 1011] ${BACKUP_ERROR_PATH}"
    exit 1
else
    if [ ! -d ${BACKUP_PATH} ];then
        mkdir -p ${BACKUP_PATH}
    fi
    cd ${BACKUP_PATH}

    db_list=`echo "show databases" | mariadb -uroot -p"${DB_PASSWORD}"`
    for db in $db_list ;do
        if [ $db == "Database" ];then
            continue
        else
            if [ ! -d $db ];then
                mkdir $db
            fi
            cd $db
        fi

        # table dump
        if [ ! -d table ];then
            mkdir table
        fi
        cd table
        table_list=`echo "show tables" | mariadb -uroot -p"${DB_PASSWORD}" $db`
        for table in $table_list ;do
            if [ $table == "Tables_in_$db" ];then
                continue
            else
                mariadb-dump --lock-tables=0 -uroot -p"${DB_PASSWORD}" $db $table > $db_$table.sql
                wait
            fi
        done

        cd ../

        # view dump
        if [ ! -d view ];then
            mkdir view
        fi
        cd view
        view_list=`echo "select table_name as views from information_schema.views where table_schema like '$db'" | mariadb -uroot -p"${DB_PASSWORD}"`
        for view in $view_list ;do
            if [ $view == "views" ];then
                continue
            else
                mariadb-dump --lock-tables=0 -uroot -p"${DB_PASSWORD}" $db $view > $db_$view.sql
                wait
            fi
        done
        cd ../../
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
