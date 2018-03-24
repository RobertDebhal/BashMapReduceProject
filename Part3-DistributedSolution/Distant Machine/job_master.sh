#! /bin/bash
if [ ! -e in_pipe ]; then
	mkfifo in_pipe
fi
if [ ! -e out_pipe ]; then
	mkfifo out_pipe
fi
if [ ! -e reduce_pipe ]; then 
	mkfifo reduce_pipe
fi
if [ ! -e map_pipe ]; then
	mkfifo map_pipe
fi
./echo.sh | nc 137.43.92.165 2012 | ./read.sh &
read input < in_pipe
echo $input
count=0
for file in $input/*
do
	echo starting map
	./map.sh $file &
	count=$((count=count+1))
done
if [ ! -e keys ]; then
	touch keys
fi
check=0
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

keys=$(cat keys)
count_keys=$(cat keys | wc -l)
echo $count_keys
echo $count_keys > out_pipe #send number of keys to master node

read check < in_pipe #block until signal received from master node
echo $check

for i in $keys; do
	echo $i
	echo $i > out_pipe
done
#Above for loop sends keys to master node

if [ ! -e new_keys ]; then
	touch new_keys
fi

received="no"
while [ "$received" != "sent" ]; do
	glob_keys=$(cat < in_pipe)
	for i in $glob_keys; do
		if [ "$i" = "sent" ]; then
			received="sent"
		else if ! grep -q "$i" new_keys; then
			echo "$i" >> new_keys
		fi
		fi
done
done
#Above while loop will read values sent by master node and append unique values to new_keys file until message that all keys have been sent received.

echo "continue" > out_pipe #let master node know that all keys saved

sent="no"
while [ "$sent" != "done" ]; do
	sent_keys=$(cat < in_pipe)
	for i in $sent_keys; do
		if [ "$i" != "done" ]; then
			echo $i >> "$i"
		elif [ "$i" = "done" ]; then
			sent="done"
		fi
	done
done
sleep 1
#Above while loop will read values sent by master node and append to files with corresponding name until message that all have been sent received.

echo "continue" > out_pipe #let master node know that files have been received.

if [ ! -e send_keys ]; then
	touch send_keys
fi
#test

sent="no"
while [ "$sent" != "done" ]; do
	keys=$(cat < in_pipe)
	for i in $keys; do
		if [ "$i" != "done" ]; then
			if ! grep -q "$i" send_keys; then
			echo $i >> send_keys
			fi
		elif [ "$i" = "done" ]; then
			sent="done"
		fi
	done
done

echo "continue" > out_pipe

send_keys=$(cat < send_keys)
for i in $send_keys; do
	file=$(cat < $i)
	append=""
	for j in $file; do
	append="$append $i"
	done
		echo $append > out_pipe
		#sleep 0.01
done
echo "done" > out_pipe
read input < in_pipe #block until signal received from master
count_new_keys=0
new_keys=$(cat new_keys)
for i in $new_keys;do
	echo starting reducer
	./reduce.sh $i &
	((count_new_keys=count_new_keys+1))
done
check_new_keys=0
while [ $check_new_keys -lt $count_new_keys ]; do
	input=$(cat < reduce_pipe)
	for i in $input; do
		echo $i
		if [ "$i" = "finished" ]; then
			((check_new_keys=check_new_keys+1))
		fi
	done
done

echo "finished"
echo "finished" > out_pipe

killall echo.sh
killall job_master.sh


