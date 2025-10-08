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

dnf module list nginx &>>$LOG_FILE
VALIDATE $? "module list nginx"

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "module disable nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "module enable nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading code"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? ""

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Coping conf file"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"

