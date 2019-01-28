#!/bin/sh

reset=\u001b[0m #resets color to normal
red="\033[0;31m"
blue="\033[0;34m"
green="\033[0;32m"
bold="\e[1m"

clear
tput civis # hide cursor
tput cup 0 0
tput bold
printf "hi"
sleep 1
tput sgr0
tput cup 0 0
printf "$bluehi"
sleep 1
echo
tput sgr0