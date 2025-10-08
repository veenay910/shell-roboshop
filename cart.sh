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
SERVICE_FILE=$PWD

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

dnf module list &>>$LOG_FILE
VALIDATE $? "module list verififcation"

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]; then
    echo "Crete roboshp user"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo "User already exist"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "create app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Download code"

cd /app &>>$LOG_FILE 
VALIDATE $? "switch app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzipping code"

npm install &>>$LOG_FILE 
VALIDATE $? "install npm packages"

cp $SERVICE_FILE/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
VALIDATE $? "coping file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable cart &>>$LOG_FILE 
VALIDATE $? "enable cart"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "start cart"



