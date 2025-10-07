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
SCRIPT_DIR=$PWD

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? nodejs_disable

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? nodejs_enable_20

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? nodejs_Install

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "npm dependencies"

cp $SCRIPT_DIR/catalogue.service  /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload &>>$LOG_FILE

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enable catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "start catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "mongodb client install"

mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load catalogue products"
