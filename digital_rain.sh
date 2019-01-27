#!/bin/sh

# Draws the digital rain from the Matrix franchise using 
# shell utilities

########
# CONFIG:
########
rain_length=10 # how long the strings get before they fade
char_count=19  # number of distinct characters to use
cursor_indexes=() # keeps track of the state of each column

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

# generates one line of characters. 
# $1 - number for string length
# $2 - number of distict characters to use
generate_string() {
  length=$1 
  diversity=$2
  output=''

  chars=($(cat characters))
  for ((i=1; i<=$length; i++)); do
    x=$(expr $RANDOM % $diversity)
    output+="${chars[$x]}"
  done
  echo $output
}

# writes a string onto the screen. 
# $1 - string to draw on screen
# $2 - integer for which column to draw down
draw() {
  input=$1
  column=$2

  if [ -z $column ]; then
    printf "Setting to default"
    column=$((width/2))
  fi

  for i in $(seq 0 ${#input}); do
      tput cup $i $column
      sleep 0.2
      tput bold
      printf "${input:$i:1}"
  done
}

# the main loop of the script.
main_loop() {
    
  for i in $(seq 0 $((#width-1))); do
    cursor_indexes[$i]=0
  done

  clear # diff btw clear and tput clear?
  x=$(generate_string $rain_length $char_count)
  draw $x $(($RANDOM%$width))
}

####################
## MAIN EXECUTION ##
####################

main_loop

# put cursor back in a convenient place
tput sgr0
tput cup $height 0
