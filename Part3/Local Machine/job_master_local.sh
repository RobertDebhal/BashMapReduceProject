#! /bin/bash
count=0
for file in $1/*
do	
	echo "starting map $file"
	./map_local.sh $file &
	count=$(($count+1))
done
if [ ! -e keys ]; then
	touch keys
fi
check=0
while [ $check -lt $count ];do
	input=$(cat < map_pipe)
	for i in $input; do
	if [ "$i" = "finished" ]; then
		check=$(($check + 1))
	fi
	if ! grep -q "$i" keys && [ "$i" != "finished" ];then
		echo "$i" >> keys
	fi
done
done

keys=$(cat keys)
for i in $keys; do
	echo $i
	echo $i > local_pipe
done

read input < local_pipe #sleep until signal from master received
echo $input

read input < local_pipe #sleep until signal from master received

count_new_keys=0
check_new_keys=0

new_keys=$(cat < new_keys)
for i in $new_keys;do
	echo starting reducer
	((count_new_keys=count_new_keys+1))
	./reduce_local.sh $i &
done

while [ $check_new_keys -lt $count_new_keys ]; do
	input=$(cat < reduce_pipe)
	for i in $input; do
	if [ "$i" = "finished" ];then
		check_new_keys=$(($check_new_keys + 1))
	else
		echo $i
	fi
	done
done
