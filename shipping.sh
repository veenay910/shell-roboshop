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
MYSQL_HOST=mysql.ddaws86s.fun

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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "install maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
echo "create system user"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
echo "roboshop user alredy exist"
fi
VALIDATE $? "Adding system user"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE 
VALIDATE $? "Downloading code"

cd /app &>>$LOG_FILE 
VALIDATE $? "switching to app directory"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping code"

mvn clean package &>>$LOG_FILE 
VALIDATE $? "clean package"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE 
VALIDATE $? "renaming package"

cp $SERVICE_FILE/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable shipping &>>$LOG_FILE 
VALIDATE $? "enable shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "start shipping"

dnf install mysql -y &>>$LOG_FILE 
VALIDATE $? "install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping