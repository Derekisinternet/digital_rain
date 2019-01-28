#!/bin/sh

# Draws the digital rain from the Matrix franchise using 
# shell utilities

########
# CONFIG:
########
rain_length=10 # how long the strings get before they fade
char_count=21  # number of distinct characters to use
raindrop_indexes=() # keeps track of the state of each column
chars=($(cat characters)) # list of symbols to display

# COLORS
reset=\u001b[0m #resets color to normal
red="\033[0;31m"
blue="\033[0;34m"
green="\033[0;32m"
bold="\e[1m"
# WINDOW SIZE
width=$(tput cols)
height=$(tput lines)


###########
## METHODS:
###########

# returns a random character
generate_char() {
  i=$((RANDOM%${#chars[@]}))
  echo "$green${chars[$i]}"
}

# draw a character at a specified location
# $1 - row
# $2 - column
draw_char() {
  tput cup 0 0; echo " drawing"
  r=$1
  c=$2
  if [ -z $r ]; then r=0; fi
  if [ -z $c ]; then c=0; fi
  tput cup $r $c
  char=$(generate_char)
  printf $char
}

# find a column that is not running and starts it
start_drip() {
  i=$((RANDOM%width))
  # find a random column with a zero
  while [ ${raindrop_indexes[$i]} -ne 0 ];  do
    i=$((RANDOM%width))
  done
  # draw and iterate
  draw_char 0 $i
  raindrop_indexes[$i]=1
}

# iterate_drips(){

# }

# set the environment and  whatnot.
init(){
  if [ -z $height ]; then return -1; fi
  if [ -z $width ]; then return -1; fi
  clear
  for i in $(seq 0 $((width-1))); do
    raindrop_indexes[$i]=0
  done
}

# the main loop of the script.
main_loop() {
  clear # diff btw clear and tput clear?
  # x=$(generate_string $rain_length $char_count)
  # draw $x $(($RANDOM%$width))
  while : 
  do
    start_drip
    sleep 0.5
  done
}

####################
## MAIN EXECUTION ##
####################

init
main_loop

# put cursor back in a convenient place
tput sgr0
tput cup $height 0
