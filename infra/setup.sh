#!/bin/bash
bucket_name="wipro-release-uk"
code_version="latest"

#Installing dependencies
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install npm -y

#Downloading latest code from s3
aws s3 cp s3://${bucket_name}/${code_version} code --recursive 
cd code
npm start
