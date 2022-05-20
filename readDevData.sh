#!/bin/bash

if [ "$1" == "TAG" ]
then
  cat repoinfo.txt | awk 'FNR == 1 {print}'
elif [[ "$1" == "LINK" ]]
then
  cat rpeoinfo.txt | awk 'FNR == 2 {print}'
elif [[ "$1" == "COMMIT" ]]
then
  cat repoinfo.txt | awk 'FNR == 3 {print}'
else
  echo "Unreachable argument!"
fi
