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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disable existing redis" 

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enable redis:7" 

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "install redis" 

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "updated to 0.0.0.0" 

sed -i 's/"protected-mode yes"/"protected-mode No"/' /etc/redis/redis.conf
VALIDATE $? "protect mode chagned to no"
# protected-mode from yes to no in /etc/redis/redis.conf
# vim /etc/redis/redis.conf

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enable redis" 

systemctl start redis &>>$LOG_FILE
VALIDATE $? "start redis" 