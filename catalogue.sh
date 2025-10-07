#!/bin/bash

# Define color variables for clarity
R='\e[31m'
G='\e[32m'
B='\e[34m'
Y='\e[33m'
N='\e[0m'

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_FILE=$( echo $0 | cut -d "." -f1 )
LOG_FILE=$LOG_FOLDER/$SCRIPT_FILE.log

USERID=$(id -u)

mkdir -p $LOG_FOLDER

if [ $USERID -ne 0 ]; then
    echo -e "Run script with Sudo permissins...  $R Validatin Failed $N " | tee -a $LOG_FILE
    exit 1
else
    echo -e "SUdo permissions validated...   $G Validatin Success $N " | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e "$2 $R Failuer $N" | tee -a $LOG_FILE
    exit 1  
    else
    echo -e "$2 $G success $N" | tee -a $LOG_FILE
    fi
}

dnf module list nodejs
VALIDATE $? nodejs
dnf module disable nodejs -y
VALIDATE $? nodejs
# dnf module enable nodejs:20 -y
# dnf install nodejs -y
# useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
# mkdir /app 
# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
# cd /app 
# unzip /tmp/catalogue.zip
# npm install 
# vim /etc/systemd/system/catalogue.service
# <MONGODB-SERVER-IPADDRESS>
# systemctl daemon-reload
# systemctl enable catalogue 
# systemctl start catalogue
# vim /etc/yum.repos.d/mongo.repo
# dnf install mongodb-mongosh -y
# mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
# show dbs
# use catalogue
# show collections
# db.products.find()

