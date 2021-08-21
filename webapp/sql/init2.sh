#!/bin/bash
set -xe
set -xu -o pipefail

CURRENT_DIR=$(cd $(dirname $0);pwd)
export MYSQL_HOST=192.168.0.12
export MYSQL_PORT=${MYSQL_PORT:-3306}
export MYSQL_USER=${MYSQL_USER:-isucon}
export MYSQL_DBNAME=${MYSQL_DBNAME:-isucondition}
export MYSQL_PWD=${MYSQL_PASS:-isucon}
export LANG="C.UTF-8"
cd $CURRENT_DIR

cat 0_Schema.sql | mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME
# ログ位置取得
mysql  -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME -e 'show master status' > cursor.tsv
cat cursor.tsv

export MYSQL_HOST=192.168.0.13
mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME --password=$MYSQL_PWD -e "stop slave\G"
cat 0_Schema.sql | mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER --password=$MYSQL_PWD $MYSQL_DBNAME

export FILE=$(cat cursor.tsv | tail -n 1 | cut -f 1)
export POS=$(cat cursor.tsv | tail -n 1 | cut -f 2)
mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME --password=$MYSQL_PWD -e "CHANGE MASTER TO MASTER_HOST='192.168.0.12',MASTER_USER='isucon',MASTER_PASSWORD='isucon',MASTER_LOG_FILE='$FILE',MASTER_LOG_POS=$POS;"
mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME --password=$MYSQL_PWD -e "start slave\G"

export MYSQL_HOST=192.168.0.12
cat 1_InitData.sql | mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME
