#! /bin/bash
if [ $# -ne 2 ]; then
	echo "Usage $0: requires subdirectory and field number as arguments."
	exit 1
fi
if ! [ -d $1 ]; then
	echo "invalid directory specified"
	exit 2
fi
if [ ! -e map_pipe ]; then #check if map_pipe exists. If not, create it.
	mkfifo map_pipe
fi
if [ ! -e reduce_pipe ];then #check if reduce_pipe exists. If not, create it
	mkfifo reduce_pipe
fi

count=0 #initialise count variable with value 0
for file in ./$1/*; #iterate over files in directory
do
	./map_part2.sh $file $2 & #start map script in background with file in directory as argument
	count=$((count=count+1)) #increment count once per map started
done

if [ ! -e keys ];then #if a file named keys doesn't exist create it
	touch keys
fi

check=0 #initialise check variable with value 0
#Below while loop reads input sent to map_pipe by map.sh scripts and increments check if the input is finished. Otherwise if the input is
#not equal to finished or in the keys file already it is appended to the keys file
while [ $check -lt $count ];do
	input=$(cat < map_pipe)
	for i in $input;do
	if [ "$i" = "finished" ];then
		check=$((check=check+1))
	fi
	if ! grep "$i" keys > /dev/null && [ "$i" != "finished" ];then
		echo $i >> keys
	fi
	done
done

keys=$(cat keys) #read keys file and store values in $keys variable
count_keys=0 #initialise count_keys variable with value 0
check_keys=0 #initialise check_keys variable with value 0

for i in $keys;do #iterate over value in $keys
	((count_keys=count_keys+1)) #increment count_keys once per reducer started
	./reduce_part2.sh $i & #start reduce.sh script in the background with value from keys as argument.
done
#Below while loop reads input sent to the reduce_pipe by the reduce.sh script and increments check_keys if the input is finished
#otherwise the input will be echoed
while [ $check_keys -lt $count_keys ];do
	input=$(cat < reduce_pipe)
	for i in $input;do
		if [ "$i" != "finished" ]; then
			echo $i
		fi
		if [ "$i" = "finished" ]; then
			((check_keys=check_keys+1))
		fi
	done
done
