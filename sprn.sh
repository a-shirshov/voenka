get_coords_from_string() {
  x_point_get_coords_from_string=$(echo $1 | cut -d ',' -f 1)
  y_point_get_coords_from_string=$(echo $1 | cut -d ',' -f 2)
  x_point_get_coords_from_string=${x_point_get_coords_from_string:1}
  y_point_get_coords_from_string=${y_point_get_coords_from_string:1}
  echo "${x_point_get_coords_from_string} ${y_point_get_coords_from_string}"
}

get_distance_between_two_dots() {
  current_x_point=$1
  x_center=$2
  current_y_point=$3
  y_center=$4

  distance=$(echo "sqrt(($current_x_point-$x_center)^2+($current_y_point-$y_center)^2)" | bc -l)
  echo $distance
}

#Number of targets
targets_num=30

#Координаты круга
x_center=2600000
y_center=2900000

#Радиус круга
radius=1300000

DirectoryTargets=/home/artyom/kr_vko/temp/GenTargets/Targets/
DirectoryDestroy=/home/artyom/kr_vko/temp/GenTargets/Destroy/
SprnLogFile=/home/artyom/kr_vko/logs/Sprn.log

declare -A sprnTargets

> $SprnLogFile

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

    if [ ${#sprnTargets[$target_id]} -eq 0 ]; then
        sprnTargets[$target_id]=$file_line
    else
        previous_coords_line=${sprnTargets[$target_id]}
        echo "Обнаружена цель ID:$target_id с координатами $current_x_point $current_y_point" >> $SprnLogFile
        > $DirectoryDestroy/$target_id
    fi
  done
done