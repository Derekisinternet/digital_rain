#!/bin/sh

chars=$(cat characters)
echo "${#chars[*]}"
i=$((RANDOM%${#chars[@]}))
echo $i