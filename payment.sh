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
SERVICE_FILE=$PWD
mkdir -p $LOG_FOLDER

USERID=$(id -u)

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
dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Install python"

id roboshop
if [ $? -ne 0 ]; then
    echo "Crete roboshp user"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo "User already exist"
fi
VALIDATE $? "add system user"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading code"

cd /app &>>$LOG_FILE
VALIDATE $? "switching to add directory"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping code"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "install dependencies"

cp $SERVICE_FILE/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "coping service file"

systemctl daemon-reload
systemctl enable payment &>>$LOG_FILE
systemctl restart payment &>>$LOG_FILE
VALIDATE $? "enable and restart payment"


