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

# All keys param
echo "All: ${allKeys}"

echo "First: ${appKey}"

echo "Rest of: ${usersKeys}"