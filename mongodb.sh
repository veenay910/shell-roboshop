#!/bin/bash

# Define color variables for clarity
R='\e[31m'
G='\e[32m'
B='\e[34m'
Y='\e[33m'
N='\e[0m'

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "Run script with Sudo permissins"
    exit 1
else
    echo "SUdo permissions validated"
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo "$2 Failuer"
    exit 1  
    else
    echo "$2 success"
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





