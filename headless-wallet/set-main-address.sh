#!/bin/bash

# Prepare env
echo "Preparing Variables..."
export HTR_WALLET_APP_MAIN_ADDR_NAME=/$DEPLOY_STAGE/hc/hathor/wallet/mainAddress
export HTR_WALLET_APP_KEY=$(aws ssm get-parameter --name "/$DEPLOY_STAGE/hc/hathor/wallet/appKey" --query "Parameter.Value" --output text)
export HTR_WALLET_ADDRESS=$(aws ssm get-parameter --name "/$DEPLOY_STAGE/hc/walletAddress" --query "Parameter.Value" --output text)
export HTR_MAIN_ADDRESS=$(curl -X GET -H "X-Wallet-Id: $HTR_WALLET_APP_KEY" ${HTR_WALLET_ADDRESS}/wallet/address/ | jq -r .address)

echo "Putting ${HTR_MAIN_ADDRESS} address as main for ${HTR_WALLET_APP_KEY} wallet..."
aws ssm put-parameter --name "$HTR_WALLET_APP_MAIN_ADDR_NAME" --value "${HTR_MAIN_ADDRESS}" --type "String" --overwrite
echo "Keys parameter ${HTR_WALLET_APP_MAIN_ADDR_NAME} created..."

echo "Keys parameters ${HTR_WALLET_APP_MAIN_ADDR_NAME} contents:"
aws ssm get-parameter --name ${HTR_WALLET_APP_MAIN_ADDR_NAME}
