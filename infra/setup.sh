#!/bin/bash
bucket_name_prefix="wipro-release"
code_version="latest"

#Installing dependencies
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install npm -y

#Downloading latest code from s3
bucket_name=$(aws s3 ls | grep -i ${bucket_name_prefix} | awk '{print $3}')
aws s3 cp s3://${bucket_name}/${code_version} code --recursive 
cd code
npm start
