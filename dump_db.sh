#!/bin/bash

# Database credentials
user=""
password=""
host=""
db_name=""

# Other options
backup_path="/path/to/your/home/_backup/mysql"
date=$(date +"%d-%b-%Y")

# Set default file permissions
umask 177

# Dump database into SQL file
/usr/bin/mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name-$date.sql
 
echo "Dump created : $backup_path/$db_name-$date.sql"
 
# Delete files older than 30 days
/usr/bin/find $backup_path/* -mtime +30 -exec rm {} \;
