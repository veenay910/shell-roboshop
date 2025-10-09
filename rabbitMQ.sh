#!/bin/bash

# Define color variables for clarity
R='\e[31m'
G='\e[32m'
B='\e[34m'
Y='\e[33m'
N='\e[0m'

LOG_FOLDER="/var/log/shell-mongo"
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

cp $PWD/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copying repo file"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "install rabbitmq-server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enable and start rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "setting up permissions"

