#!/bin/sh

# Draws the digital rain from the Matrix franchise using 
# shell utilities

########
# CONFIG:
########

# WINDOW SIZE
WIDTH=$(tput cols)
HEIGHT=$(tput lines)

RAIN_LENGTH=$(( (HEIGHT*3)/4 )) # how long the strings get before they fade
RAINDROP_COORDINATES=() # keeps track of the state of each column
VOID_COORDINATES=()
CHARS=($(cat characters)) # list of symbols to display

# COLORS
RESET="\e[0m" #resets color to normal
red="\e[0;31m"
blue="\e[0;34m"
green="\e[0;32m"
bold="\e[1m"
dim="\e[2m"
white_bg="\e[47m"
black_bg="\e[40m"

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

# finds a column that is not running and starts it
start_drip() {
  i=$((RANDOM%WIDTH))
  # find a random column with a zero
  while [[ "${RAINDROP_COORDINATES[$i]}" -ne 0 ]];  do
    i=$((RANDOM%WIDTH))
  done
  # draw and iterate
  draw_char 0 $i $green $bold $white_bg
  RAINDROP_COORDINATES[$i]=1
}

# Returns a list with the item at index removed
# Usage: list=($(remove $list $index))
# $1 - index
# $2 - list
remove() {
  local i=$1
  shift 1
  local list=($@)

  if [[ "$i" -lt "${#list[@]}" ]]; then
    # if index = 0 then set drops to a sigle slice
    if [[ $i -eq 0 ]]; then
      tmp=("${list[@] :1}")
      list=$tmp
      unset tmp
    else
        tmp_a=("${list[@] :0:$i}")
        tmp_b=("${list[@] :$((i+1))}")
        list=(${tmp_a[@]}); list+=(${tmp_b[@]})
        unset tmp_a tmp_b
    fi
  fi
  echo ${list[@]}
}

# go through all the columns that have drops and iterate
iterate_drops() {
  # copy indexes into a list.
  drop_indexes=( $( seq 0 $((${#RAINDROP_COORDINATES[@]}-1)) ) )
  while [[ ${#drop_indexes[@]} -gt 1 ]]; do
    # get a random drop from RAINDROP_INDEXES by taking a random index from drop_indexes
    # this will make more sense when we start removing items from drop_indexes
    length=${#drop_indexes[@]}
    r_index=$((RANDOM%length))
    r_column=${drop_indexes[$r_index]}
    # row coordinate for that column
    curr_row="${RAINDROP_COORDINATES[$r_column]}"
    if [[ $curr_row -gt 0 ]]; then  # row 0 is handled by start_drip()
      draw_char $((curr_row-1)) $r_column $green $bold
      # if characters write to bottom of screen:
      if [[ $curr_row -eq $(($HEIGHT-1)) ]]; then
        if [[ VOID_COORDINATES[$r_index] -gt 0 ]]; then
          if [[ VOID_COORDINATES[$r_index] -gt 10 ]]; then
            RAINDROP_COORDINATES[$r_column]=0
          fi
        else
          draw_char $curr_row $r_column $green $bold
          VOID_COORDINATES[$r_index]=1
        fi
      else
        draw_char $curr_row $r_column $green $bold $white_bg
        new_row=$(($curr_row+1))
        RAINDROP_COORDINATES[$r_column]=$new_row
      fi
    fi
    # remove iterated drop from drop_indexes, so that we get another random column instead of iterating again
    drop_indexes=($(remove $r_index ${drop_indexes[@]}) )
  done
}

# Clean up the screen by erasing columns
iterate_voids() {
  tput civis
  for i in $(seq 0 $((${#VOID_COORDINATES[@]}-1))); do
    row=${VOID_COORDINATES[$i]}
    if [[ $row -gt 0 ]]; then
      if [ $row -eq 1 ]; then
        tput cup $((row-1)) $i
        printf " "
      fi
      tput cup $row $i
      printf " "
      VOID_COORDINATES[$i]=$((VOID_COORDINATES[$i]+1))
      if [[ $row -eq $((HEIGHT-1)) ]]; then
        VOID_COORDINATES[$i]=0
      fi
    fi 
  done
  tput cvvis
}

# clean up the terminal on exit
key_trap() {
  tput cup $HEIGHT 0
  tput sgr0
  exit 0
}

# set the environment and  whatnot.
init() {
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
