#!/bin/bash

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-03fe2ffe4f5201850
ZONE_ID=Z04178031FEO6E3KYJ2X5
DOMAIN_NAME=ddaws86s.fun

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != frontend ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME=$instance.$DOMAIN_NAME
    else
        IP=(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME=$DOMAIN_NAME

    fi
      echo "$instance: $IP"
      # Creates route 53 records based on env name

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '

done




