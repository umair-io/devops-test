#!/bin/bash -x
exec > /tmp/part-001.log 2>&1

#Install nodejs on Amazon Linux
cat > /tmp/subscript.sh << EOF
curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

echo 'export NVM_DIR="/home/ec2-user/.nvm"' >> /home/ec2-user/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ec2-user/.bashrc

# Dot source the files to ensure that variables are available within the current shell
. ~/.nvm/nvm.sh

# Install NVM
nvm install node
EOF

chown ec2-user:ec2-user /tmp/subscript.sh && chmod a+x /tmp/subscript.sh
sleep 1; su - ec2-user -c "/tmp/subscript.sh"

#setting vars
bucket_name_prefix="wipro-release"
code_version="latest"

#Downloading latest code from s3
bucket_name=$(aws s3 ls | grep -i ${bucket_name_prefix} | awk '{print $3}')
cd /home/ec2-user
aws s3 cp s3://${bucket_name}/${code_version} code --recursive

su - ec2-user -c "cd code; npm start"