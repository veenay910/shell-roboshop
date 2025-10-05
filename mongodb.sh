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





