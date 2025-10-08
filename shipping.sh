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

dnf install maven -y
VALIDATE $? "install maven"

id roboshop
if [ $? -ne 0 ]; then
echo "create system user"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
echo "roboshop user alredy exist"
fi
VALIDATE $? "Adding system user"

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Downloading code"

cd /app 
VALIDATE $? "switching to app directory"

unzip /tmp/shipping.zip
VALIDATE $? "unzipping code"

mvn clean package 
VALIDATE $? "clean package"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "renaming package"

cp $SERVICE_FILE/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable shipping 
VALIDATE $? "enable shipping"

systemctl start shipping
VALIDATE $? "start shipping"

dnf install mysql -y 
VALIDATE $? "install mysql"

mysql -h mysql.ddaws86s.fun -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? ""

mysql -h mysql.ddaws86s.fun -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? ""

mysql -h mysql.ddaws86s.fun -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? ""

systemctl restart shipping
VALIDATE $? ""