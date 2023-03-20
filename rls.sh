#!/bin/bash
#set -x
#Координаты точки
x_point=4
y_point=4

#Координаты круга
x_center=3
y_center=3

#Радиус круга
radius=3

#Углы сектора
start_angle=10
end_angle=45

#Попадает ли точка в радиус круга
distance=$(echo "sqrt(($x_point-$x_center)^2+($y_point-$y_center)^2)" | bc -l)

echo $distance

if [ $(echo "$distance > $radius" | bc ) -eq 1 ]; then
    echo "Точка вне круга"
    exit 0
fi

x_from_center=$((x_point - x_center))
y_from_center=$((y_point - y_center))

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


getAngle() {
    local_point_x=$1
    local_point_y=$2
    
    ox_x=1
    ox_y=0

    cos_angle=$(echo "($local_point_x*$ox_x + $local_point_y*$ox_y)/(sqrt($local_point_x^2 + $local_point_y^2)*sqrt($local_point_y^2 + $ox_y^2))" | bc -l)
    angle=$(arccos $cos_angle)
    degree_angle=$(echo "$angle*180/3.141592" | bc -l)
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
        echo 1
      else
        echo 0
      fi
    else
      if [ $(echo "$angle_is_in_sector >= $start_angle_is_in_sector" | bc) -eq 1 ] && [ $(echo "$angle_is_in_sector <= $end_angle_is_in_sector" | bc) -eq 1 ]; then
        echo 1
      else
        echo 0
      fi
    fi
}

if [ $x_from_center -ge 0 ] && [ $y_from_center -ge 0 ]; then
  echo "Точка лежит в первой четверти"
  angle=$(getAngle $x_from_center $y_from_center)
  echo $angle
  found_point=$(is_in_sector $angle)
  echo $found_point
elif [ $x_from_center -le 0 ] && [ $y_from_center -ge 0 ]; then
  echo "Точка лежит во второй четверти"
  angle=$(getAngle $x_from_center $y_from_center)
  echo $angle
  found_point=$(is_in_sector $angle)
  echo $found_point
elif [ $x_from_center -le 0 ] && [ $y_from_center -le 0 ]; then
  echo "Точка лежит в третьей четверти"
  angle=$(getAngle $x_from_center $y_from_center)
  angle=$(echo "180 + (180-$angle)" | bc -l)
  echo $angle
  found_point=$(is_in_sector $angle)
  echo $found_point
elif [ $x_from_center -ge 0 ] && [ $y_from_center -le 0 ]; then
  echo "Точка лежит в четвертой четверти"
  angle=$(getAngle $x_from_center $y_from_center)
  angle=$(echo "360-$angle" | bc -l)
  echo $angle
  found_point=$(is_in_sector $angle)
  echo $found_point
else
  echo "Ошибка"
fi