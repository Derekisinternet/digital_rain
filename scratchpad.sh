#!/bin/sh



# for i in {0..255} ; do
#   printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
#   if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
#      printf "\n";
#   fi
# done

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

s=($(seq 0 6))
echo "s = ${s[@]}"
s=($(remove 4 ${s[@]}))
echo "s = ${s[@]}"
echo "s length: ${#s[@]}"