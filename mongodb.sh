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

dnf list installed mongodb
if [ $? -ne 0 ]; then
    echo "Mongodb not exist"
    dnf install mongodb -y
else
    echo "Mongodb already exist... skipping"
fi





