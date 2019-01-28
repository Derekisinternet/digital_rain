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
  echo "${chars[$i]}"
}

# generates one line of characters. 
# $1 - number for string lengt
generate_string() {
  length=$1
  output=''

  for ((i=1; i<=$length; i++)); do
    output+=$(generate_char)
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

# find a column that is not running and starts it
# start_drip() {
#   i=$((RANDOM%width))
#   if [ co]
# }

# iterate_drips(){

# }

# set the environment and  whatnot.
init(){
  for i in $(seq 0 $((width-1))); do
    raindrop_indexes[$i]=0
  done
}

# the main loop of the script.
main_loop() {
  clear # diff btw clear and tput clear?
  x=$(generate_string $rain_length $char_count)
  draw $x $(($RANDOM%$width))
}

####################
## MAIN EXECUTION ##
####################

init
main_loop

# put cursor back in a convenient place
tput sgr0
tput cup $height 0
