#!/bin/bash

# Install NodeJS
echo "Installing NodeJS..."
cd /home/ec2-user
source /home/ec2-user/.bash_profile
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 16
echo "Checking version ..."
node -e "console.log('Running Node.js ' + process.version)" > /home/ec2-user/headless-wallet.log

# Clone last version of the wallet source code
echo "Cloning wallet repo..."
cd /home/ec2-user
mkdir polygon-wallet-headless-api
cd polygon-wallet-headless-api
aws s3 sync s3://${STAGE_LOCATION}/src/polygon-wallet-headless-api . --exclude '*' --include 'package*' --include 'src/*' --include 'scripts/*' --delete

echo "Installing packages..."
npm install

echo "Done."