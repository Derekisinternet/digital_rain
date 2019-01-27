#!/bin/sh

# take control of a terminal window and draw something


# COLORS
reset=\u001b[0m #resets color to normal
red="\033[0;31m"
blue="\033[0;34m"
green="\033[0;32m"
# WINDOW SIZE
width=$(tput cols)
height=$(tput lines)
echo "window width: $width"
echo "window height: $height"

# generates one line of characters. expects a number argument for string length
generate_string() {
  length=$1 
  diversity=19
  output=''

  chars=($(cat characters))
  for ((i=1; i<=$length; i++)); do
    x=$(expr $RANDOM % $diversity)
    output+="${chars[$x]}"
  done
  echo $output
}

# writes a string onto the screen. Expects a string input
draw() {
  input=$1
  for i in $(seq 0 ${#input}); do
      tput cup $i $((width/2))
      printf "${input:$i:1}"
      sleep 0.2
  done
}

# the main loop of the script.
main_loop() {
  x=$(generate_string 10)
  draw $x
}

## MAIN EXECUTION ##

clear # diff btw clear and tput clear?
tput cup 0 0
#tput bold
main_loop

tput cup $height 0
