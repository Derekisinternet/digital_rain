#!/bin/sh

# Draws the digital rain from the Matrix franchise using 
# shell utilities

########
# CONFIG:
########
RAIN_LENGTH=15 # how long the strings get before they fade
RAINDROP_COORDINATES=() # keeps track of the state of each column
VOID_COORDINATES=()
CHARS=($(cat characters)) # list of symbols to display

# WINDOW SIZE
WIDTH=$(tput cols)
HEIGHT=$(tput lines)

# COLORS
RESET="\e[22m" #resets color to normal
red="\e[0;31m"
blue="\e[0;34m"
green="\e[0;32m"
bold="\e[1m"
dim="\e[2m"
bright="\e[1m"

###########
## METHODS:
###########

# returns a random character
generate_char() {
  i=$((RANDOM%${#CHARS[@]}))
  echo ${CHARS[$i]}
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
  i=$((RANDOM%WIDTH))
  # find a random column with a zero
  while [[ "${RAINDROP_COORDINATES[$i]}" -ne 0 ]];  do
    i=$((RANDOM%WIDTH))
  done
  # draw and iterate
  draw_char 0 $i $green $bold
  RAINDROP_COORDINATES[$i]=1
}

# make characters behind lead character dimmer
# $1 - row
# $2 - column
# $3 - length of the fade
fade() {
  row=$1
  col=$2
  length=$3
  new_row=$((row-length))

  if [[ $new_row -ge 0 ]]; then
    tput cup $new_row $col
    printf " "
  fi
}

# iterate through all the columns that have drops and iterate
iterate_drops(){
  # copy indexes
  drops=( $(seq 0 $((${#RAINDROP_COORDINATES[@]}-1)) ) )
  while [[ ${#drops[@]} -gt 1 ]]; do
    length=${#drops[@]}
    # get a random column index
    r_column=$((RANDOM%length))
    # row coordinate for that column
    curr_row="${RAINDROP_COORDINATES[$r_column]}"
    if [[ $curr_row -gt 0 ]]; then  # row 0 is handled by start_drip()
      # if characters write to bottom of screen:
      if [[ $curr_row -eq $(($HEIGHT-1)) ]]; then
        RAINDROP_COORDINATES[$r_column]=0
        VOID_COORDINATES[$r_column]=$((curr_row-RAIN_LENGTH))
      else
        draw_char $curr_row $r_column
        fade $curr_row $r_column $RAIN_LENGTH
        new_row=$(($curr_row+1))
        RAINDROP_COORDINATES[$r_column]=$new_row
      fi
    fi
    # remove index from list
    # if index = 0 then set drops to a sigle slice
    if [[ $r_column -eq 0 ]]; then
        tmp=("${drops[@] :1}")
        drops=$tmp
        unset tmp
    else
        tmp_a=("${drops[@] :0:$r_column}")
        tmp_b=("${drops[@] :$((r_column+1))}")
        drops=(${tmp_a[@]}); drops+=(${tmp_b[@]})
        unset tmp_a tmp_b
    fi
  done
}

# Clean up the screen by erasing columns
iterate_voids() {
  for i in $(seq 0 $((${#VOID_COORDINATES[@]}-1))); do
    row=${VOID_COORDINATES[$i]}
    if [[ $row -gt 0 ]]; then
        tput cup $row $i
        printf " "
        VOID_COORDINATES[$i]=$((VOID_COORDINATES[$i]+1))
      if [[ $row -eq $((HEIGHT-1)) ]]; then
        VOID_COORDINATES[$i]=0
      fi
    fi 
  done
}

# clean up the terminal on exit
key_trap() {
  tput cup $HEIGHT 0
  tput sgr0
  exit 0
}

# set the environment and  whatnot.
init(){
  if [ -z $HEIGHT ]; then return -1; fi
  if [ -z $WIDTH ]; then return -1; fi
  clear
  for i in $(seq 0 $((WIDTH-1))); do
    RAINDROP_COORDINATES[$i]=0
    VOID_COORDINATES[$i]=0
  done
  trap "key_trap" 2
}

# the main loop of the script.
main_loop() {
  clear
  while : 
  do
    start_drip
    iterate_drops
    iterate_voids
  done
}

####################
## MAIN EXECUTION ##
####################

init
main_loop

# put cursor back in a convenient state and location
tput sgr0
tput cup $HEIGHT 0
