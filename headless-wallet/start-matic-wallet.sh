#!/bin/bash

# Prepare seeds
echo "Preparing Seeds..."
cd /home/ec2-user/
source /home/ec2-user/.bash_profile

# Fetch secret
aws secretsmanager get-secret-value --secret-id ${MATIC_WALLETS_SECRET_NAME} --query SecretString --output text > matic_seeds
if [ $? -eq 0 ]
then
  echo "Found ${MATIC_WALLETS_SECRET_NAME} secret, continuing..."
else
  echo ""
  echo "Aborting wallet start..."
  echo "You must configure ${MATIC_WALLETS_SECRET_NAME} secret using this instance, delete the stack and create it again."
  exit 1;
fi

# mapfile -t arr < <(jq -r 'keys[]' matic_seeds)
# printf "%s\n" ${arr[@]} > matic_seed_keys
# sed -i '1s/^/seeds: /' matic_seeds
# echo , >> matic_seeds

echo ""
echo "Got this seeds (words truncated):"
cat matic_seeds | cut -c -40

# Read the JSON file
json=$(cat matic_seeds)

# Create a map of the elements in the JSON file
declare -A map
while read -r key value; do
  map[$key]="$value"
done < <(jq -r 'to_entries[] | "\(.key) \(.value)"' <<< "${json}")

echo "Starting node..."
cd /home/ec2-user/polygon-wallet-headless-api
nohup npm start > /home/ec2-user/logs/polygon-headless-wallet.log 2>&1 &

echo "Waiting 15 seconds for node to go up..."
sleep 15

# Init wallets from seed and check status
# while read line; do echo "$line" && curl -X POST --data "wallet-id=$line" --data "seedKey=$line" http://localhost:8000/start && echo " "; done < ../seed_keys
# while read line; do echo "$line" && curl -X GET -H "X-Wallet-Id: $line" http://localhost:8000/wallet/status/ && echo " "; done < ../seed_keys

# Loop through the keys in the map and print the values
for key in "${!map[@]}"; do
  value=${map[$key]}
  echo "${key}: ${value}" | cut -c -40
  curl --location --request POST 'http://localhost:8001/start' \
       --header 'Content-Type: application/json' \
       --data-raw "{\"wallet-id\": \"${key}\", \"seedKey\": \"${value}\"}"
done

echo "Done."
