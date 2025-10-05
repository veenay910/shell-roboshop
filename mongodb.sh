#!/bin/bash

# Define color variables for clarity
R='\e[31m'
G='\e[32m'
B='\e[34m'
Y='\e[33m'
N='\e[0m'

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo -e "Run script with Sudo permissins...  $R Validatin Failed $N "
    exit 1
else
    echo -e "SUdo permissions validated...   $G Validatin Success $N   "
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo "$2 $R Failuer $N"
    exit 1  
    else
    echo "$2 $G success $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mango repo"

dnf install mongodb-org -y
VALIDATE $? "Install Mongodb"

systemctl enable mongod
VALIDATE $? "Enable Mongodb"

systemctl start mongod 
VALIDATE $? "Start  Mongodb"





