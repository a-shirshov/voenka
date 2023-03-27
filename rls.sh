#!/bin/bash

arccos () {
    scale=3
    if (( $(echo "$1 == 0" | bc -l) )); then
        echo "a(1)*2" | bc -l
    elif (( $(echo "(-1 <= $1) && ($1 < 0)" | bc -l) )); then
        echo "scale=${scale}; a(1)*4 - a(sqrt((1/($1^2))-1))" | bc -l
    elif (( $(echo "(0 < $1) && ($1 <= 1)" | bc -l) )); then
        echo "scale=${scale}; a(sqrt((1/($1^2))-1))" | bc -l
    else
        echo "input out of range"
        return 1
    fi
}

get_distance_between_two_dots() {
  current_x_point=$1
  x_center=$2
  current_y_point=$3
  y_center=$4

  distance=$(echo "sqrt(($current_x_point-$x_center)^2+($current_y_point-$y_center)^2)" | bc -l)
  echo $distance
}

getAngle() {
    local_point_x=$1
    local_point_y=$2
    
    ox_x=1
    ox_y=0
    cos_angle=$(echo "($local_point_x*$ox_x + $local_point_y*$ox_y)/(sqrt($local_point_x^2 + $local_point_y^2)*sqrt($ox_x^2 + $ox_y^2))" | bc -l)
    angle=$(arccos $cos_angle)
    degree_angle=$(echo "$angle*180/3.1415926535" | bc -l)
    echo $degree_angle
}

is_in_sector() {
    start_angle_is_in_sector=$start_angle
    end_angle_is_in_sector=$end_angle
    angle_is_in_sector=$1

    if [ $start_angle_is_in_sector -gt $end_angle_is_in_sector ]; then
      cond1=$(echo "$angle_is_in_sector >= $start_angle_is_in_sector" | bc)
      cond2=$(echo "$angle_is_in_sector <= $end_angle_is_in_sector" | bc)
      (( $cond1 || $cond2 ))
      cond1_and_cond2=$?
      if [[ $cond1_and_cond2 -eq 0 ]]; then
        echo 0
      else
        echo 1
      fi
    else
      if [ $(echo "$angle_is_in_sector >= $start_angle_is_in_sector" | bc) -eq 1 ] && [ $(echo "$angle_is_in_sector <= $end_angle_is_in_sector" | bc) -eq 1 ]; then
        echo 0
      else
        echo 1
      fi
    fi
}


check_point() {
  angle=$(getAngle $x_from_center $y_from_center)
  if [ $y_from_center -ge 0 ]; then
    angle=$(echo "360-$angle" | bc -l)
  fi
  found_point=$(is_in_sector $angle)
  echo $found_point
}

get_coords_from_string() {
  x_point_get_coords_from_string=$(echo $1 | cut -d ',' -f 1)
  y_point_get_coords_from_string=$(echo $1 | cut -d ',' -f 2)
  x_point_get_coords_from_string=${x_point_get_coords_from_string:1}
  y_point_get_coords_from_string=${y_point_get_coords_from_string:1}
  echo "${x_point_get_coords_from_string} ${y_point_get_coords_from_string}"
}

calculate_speed() {
  first_x_coord_calculate_speed=$1
  second_x_coord_calculate_speed=$2
  first_y_coord_calculate_speed=$3
  second_y_coord_calculate_speed=$4

  x_speed_calculate_speed=$(echo "$second_x_coord_calculate_speed - $first_x_coord_calculate_speed" | bc -l)
  y_speed_calculate_speed=$(echo "$second_y_coord_calculate_speed - $first_y_coord_calculate_speed" | bc -l)
  echo "${x_speed_calculate_speed} ${y_speed_calculate_speed}"
}

get_line_formula() {
  first_x_coord_get_line_formula=$1
  second_x_coord_get_line_formula=$2
  first_y_coord_get_line_formula=$3
  second_y_coord_get_line_formula=$4

  k_get_line_formula=$(echo "scale=3; ($second_y_coord_get_line_formula - $first_y_coord_get_line_formula)/($second_x_coord_get_line_formula-$first_x_coord_get_line_formula)" | bc -l)
  b_get_line_formula=$(echo "scale=3; $first_y_coord_get_line_formula - $k_get_line_formula*$first_x_coord_get_line_formula" | bc -l)
  echo "${k_get_line_formula} ${b_get_line_formula}"
}

is_to_sprn() {
  A_is_to_sprn=$1
  A_is_to_sprn=$(echo "$A_is_to_sprn*-1" | bc -l)
  B_is_to_sprn=$2
  C_is_to_sprn=$3
  C_is_to_sprn=$(echo "$C_is_to_sprn*-1" | bc -l)
  x_point_is_to_sprn=$4
  y_point_is_to_sprn=$5
  radius_is_to_sprn=$6

  chisl_is_to_sprn=$(echo "$A_is_to_sprn*$x_point_is_to_sprn + $B_is_to_sprn*$y_point_is_to_sprn + $C_is_to_sprn" | bc -l)
  if [ $(echo "$chisl_is_to_sprn < 0" | bc -l) -eq 1 ]; then
    chisl_is_to_sprn=$(echo "$chisl_is_to_sprn*-1" | bc -l)
  fi
  distance_is_to_sprn=$(echo "$chisl_is_to_sprn/(sqrt($A_is_to_sprn^2+$B_is_to_sprn^2))" | bc -l)
  if [ $(echo "$distance_is_to_sprn < $radius_is_to_sprn" | bc -l) -eq 1 ]; then
    echo 0
  else
    echo 1
  fi
}

#Number of targets
targets_num=30

#Координаты круга
x_center=7000000
y_center=5000000

#Радиус круга
radius=7000000

#Углы сектора
start_angle=0
end_angle=90

#СПРН
x_sprn=2600000
y_sprn=2900000
radius_sprn=1300000

DirectoryTargets=/home/artyom/kr_vko/temp/GenTargets/Targets/
RlsLogFile=/home/artyom/kr_vko/logs/Darial.log

declare -A rlsTargets

> $RlsLogFile

while :
do
  sleep 5
  for file in $(ls $DirectoryTargets -t | head -n $targets_num)
  do
    #echo $file
    target_id=${file:12:18}
    #cat $DirectoryTargets$file
    file_line=$(cat $DirectoryTargets$file)
    current_coords=$(get_coords_from_string $file_line)
    read current_x_point current_y_point <<< "$current_coords"
    current_distance=$(get_distance_between_two_dots $current_x_point $x_center $current_y_point $y_center)

    #echo $current_distance

    if [ $(echo "$current_distance > $radius" | bc ) -eq 1 ]; then
        echo "Точка вне круга"
        continue
    fi

    x_from_center=$((current_x_point - x_center))
    y_from_center=$((current_y_point - y_center))

    #Попадает ли точка в радиус круга
    found_point=$(check_point)

    if [ $found_point -eq 0 ]; then
      if [ ${#rlsTargets[$target_id]} -eq 0 ]; then
        rlsTargets[$target_id]=$file_line
      else
        previous_coords_line=${rlsTargets[$target_id]}
        if [ "$previous_coords_line" != "$file_line" ]; then
          echo "Обнаружена цель ID:$target_id с координатами $current_x_point $current_y_point" >> $RlsLogFile
          previous_coords=$(get_coords_from_string $previous_coords_line)
          read previous_x_point previous_y_point <<< "$previous_coords"
          target_speeds=$(calculate_speed $previous_x_point $current_x_point $previous_y_point $current_y_point)
          read target_speed_x target_speed_y <<< "$target_speeds"
          previous_distance=$(get_distance_between_two_dots $previous_x_point $x_center $previous_y_point $y_center)
          if [ $(echo "$current_distance < $previous_distance" | bc -l) -eq 1 ]; then
            line_koef=$(get_line_formula $previous_x_point $current_x_point $previous_y_point $current_y_point)
            read k b <<< "$line_koef"
            if [ $(is_to_sprn $k 1 $b $x_sprn $y_sprn $radius_sprn) -eq 0 ]; then
              echo "Цель ID:$target_id движется в направлении СПРО" >> $RlsLogFile 
            fi
          fi
        fi
        rlsTargets[$target_id]=$file_line
      fi
    fi
  done
done