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

# generates one line of characters.
generate_string() {
  diversity=$1
  if [ -z "$diversity" ]; then
    diversity=7 # not sure this is right . . .
  fi

  chars=($(cat characters))
  for ((i=1; i<=$width; i++)); do
    x=$(expr $RANDOM % $diversity)
    printf "${chars[$x]}"
  done
}

# the main loop of the script.
main_loop() {
  for i in $(seq 1 $height); do
    echo $green$(generate_string 19)
  done
}

## MAIN EXECUTION ##

clear # diff btw clear and tput clear?
tput cup 0 0
tput bold

main_loop
