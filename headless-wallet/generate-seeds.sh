#!/bin/bash
if [ $# -eq 0 ]; then
   echo "Missing wallet list parameter!"
   echo "Usage: ./generate-seeds.sh wallet1,wallet2,walletN"
   exit 1
fi

declare -a wallets=($(echo $1 | tr "," "\n"))

declare lastElement=${wallets[-1]}

declare allKeys=$1
declare appKey=${wallets[0]}
declare usersKeys=${allKeys#*,}

echo "{" > raw_seeds
## now loop through the above array
for wallet in "${wallets[@]}"
do
   echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * "
   echo "*** Creating seed for $wallet"
   npm run generate_words > $wallet
   if [ $wallet != $lastElement ]; then
      echo "   \"$wallet\": \"`tail -n 1 $wallet`\"," >> raw_seeds
   else
      echo "   \"$wallet\": \"`tail -n 1 $wallet`\"" >> raw_seeds
   fi
done
echo "}" >> raw_seeds

echo ""
echo "Seeds created (words truncated):"
cat raw_seeds | cut -c -80

# All keys param
aws ssm put-parameter --name ${HTR_WALLETS_PARAM_NAME} --value $allKeys --type "String" --overwrite
echo "Keys parameter ${HTR_WALLETS_PARAM_NAME} created..."

echo "Keys parameters ${HTR_WALLETS_PARAM_NAME} contents:"
aws ssm get-parameter --name ${HTR_WALLETS_PARAM_NAME}

# App key param
aws ssm put-parameter --name ${HTR_WALLET_APP_KEY_NAME} --value ${appKey} --type "String" --overwrite
echo "Keys parameter ${HTR_WALLET_APP_KEY_NAME} created..."

echo "Keys parameters ${HTR_WALLET_APP_KEY_NAME} contents:"
aws ssm get-parameter --name ${HTR_WALLET_APP_KEY_NAME}

# Users keys param
aws ssm put-parameter --name ${HTR_WALLET_USERS_KEYS_NAME} --value "${usersKeys}" --type "String" --overwrite
echo "Keys parameter ${HTR_WALLET_USERS_KEYS_NAME} created..."

echo "Keys parameters ${HTR_WALLET_USERS_KEYS_NAME} contents:"
aws ssm get-parameter --name ${HTR_WALLET_USERS_KEYS_NAME}

# Seed Secret
aws secretsmanager create-secret --name ${HTR_WALLETS_SECRET_NAME} --secret-string "`cat ./raw_seeds`"
echo "Secret ${HTR_WALLETS_SECRET_NAME} created..."

echo "Secret ${HTR_WALLETS_SECRET_NAME} contents (truncated):"
aws secretsmanager get-secret-value --secret-id ${HTR_WALLETS_SECRET_NAME} --query SecretString --output text | cut -c -40
