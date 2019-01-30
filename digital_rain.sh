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
RESET="\e[22m" #resets color to normal
red="\e[0;31m"
blue="\e[0;34m"
green="\e[0;32m"
bold="\e[1m"
dim="\e[2m"
bright="\e[1m"
# WINDOW SIZE
width=$(tput cols)
height=$(tput lines)


###########
## METHODS:
###########

# returns a random character
generate_char() {
  i=$((RANDOM%${#chars[@]}))
  echo ${chars[$i]}
}

# draw a character at a specified location
# $1 - row
# $2 - column
# $3 - optional color code to attach to output
# $4 - optional intensity. Defaults to normal
draw_char() {
  r=$1
  c=$2
  color=$3
  intensity=$4
  if [ -z $r ]; then r=0; fi
  if [ -z $c ]; then c=0; fi
  if [[ "$itensity" != "bold" && "$intensity" != "dim" ]]; then 
    intensity=$(tput sgr0)
  else
    intensity=$(tput "$intensity")
  fi
  if [ -z $color ]; then color=$(tput setaf 2); fi

  tput cup $r $c
  char=$(generate_char)
  printf "$intensity$color$char$RESET"
}

# finds a column that is not running and starts it
start_drip() {
  i=$((RANDOM%width))
  # find a random column with a zero
  while [[ "${raindrop_indexes[$i]}" -ne 0 ]];  do
    i=$((RANDOM%width))
  done
  # draw and iterate
  draw_char 0 $i $green $bold
  raindrop_indexes[$i]=1
}

# iterate through all the columns that have drops and iterate
iterate_drops(){
  # # starting work on iterating drops in random columns
  # drops=${raindrop_indexes[*]}
  # while [[ ${#drops} -gt 0 ]]; do
  #   length=$((${#drips}-1))

  # done

  for i in $( seq 0 $((width-1)) ); do
    curr_row="${raindrop_indexes[$i]}"
    if [[ $curr_row -gt 0 ]]; then
      if [[ $curr_row -eq $(($height-1)) ]]; then
        raindrop_indexes[$i]=0
      else
        draw_char $curr_row $i
        fade $curr_row $i
        new_row=$(($curr_row+1))
        raindrop_indexes[$i]=$new_row
      fi
    fi
  done
}

# make characters behind lead character dimmer
# $1 - row
# $2 - column
# $3 - length of the fade
fade() {
  row=$1
  col=$2
  length=$3

  tput cup $row $column

  while [[ $length -ne 0 ]]; do
    length=$((length-1))
    row=$((row-1))
    tput cup $row $column
  done

}

# clean up the terminal on exit
key_trap() {
  tput cup $height 0
  tput sgr0
  exit 0
}

# set the environment and  whatnot.
init(){
  if [ -z $height ]; then return -1; fi
  if [ -z $width ]; then return -1; fi
  clear
  for i in $(seq 0 $((width-1))); do
    raindrop_indexes[$i]=0
  done
  trap "key_trap" 2
}

# the main loop of the script.
main_loop() {
  clear # diff btw clear and tput clear?
  while : 
  do
    start_drip
    iterate_drops
    # sleep 0.2
  done
}

####################
## MAIN EXECUTION ##
####################

init
main_loop

# put cursor back in a convenient state and location
tput sgr0
tput cup $height 0
