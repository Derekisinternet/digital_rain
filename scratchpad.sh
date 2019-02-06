#!/bin/sh



# for i in {0..255} ; do
#   printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
#   if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
#      printf "\n";
#   fi
# done
CHARS=($(cat characters))
RESET="\e[0m" #resets color to normal
red="\e[0;31m"
blue="\e[0;34m"
green="\e[0;32m"
bold="\e[1m"
dim="\e[2m"
bright="\e[1m"
white_bg="\e[47m"

generate_char() {
  i=$((RANDOM%${#CHARS[@]}))
  echo ${CHARS[$i]}
}

draw_char() {
  r=$1
  c=$2
  color=$3
  intensity=$4
  background=$5
  if [ -z $r ]; then r=0; fi
  if [ -z $c ]; then c=0; fi
  if [ -z $color ]; then color=$green; fi
  if [ -z $background ]; then 
    background=$black_bg
  fi

  tput cup $r $c
  char=$(generate_char)
  printf "$color$intensity$background$char$RESET"
}

clear
# draw a blank cursor
printf "$red$bright hello $RESET"
tput cup 1 0 
printf "$red hello $RESET"
draw_char 2 0 $red $bold $white_bg
echo