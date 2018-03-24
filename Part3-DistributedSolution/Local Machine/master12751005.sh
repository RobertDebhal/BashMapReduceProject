#! /bin/bash
if [ ! -e map_pipe ]; then 
	mkfifo map_pipe
fi
if [ ! -e reduce_pipe ]; then
 mkfifo reduce_pipe
fi
./echo_local.sh | nc -l 2012 | ./read_local.sh &
#Above line sets up the network connection to the ditant machine
#echo.sh reads from the out_pipe and pipes this output to nc which sends input to the distant connected machine
#nc will pipe its output (recieved from nc on the distant machine) to read.sh which will read this and echo it to the in_pipe

if [ ! -e local_pipe ]; then
	mkfifo local_pipe
fi
if [ ! -e out_pipe ]; then
	mkfifo out_pipe
fi
if [ ! -e in_pipe ]; then
	mkfifo in_pipe
fi
echo ./files > out_pipe 
#Above line sends directory name containing file(s) to distant job_master.sh

./job_master_local.sh ./files &
#Above line starts local job_master.sh in the background with directory name containing file(s) as argument 

keyslocal=$(cat < local_pipe) #read key values from the local pipe and store these values in the variable $keyslocal

if [ ! -e global_keys ]; then #Create global_keys file if it doesn't exist
	touch global_keys
fi

for i in $keyslocal; do
	if ! grep -q "$i" global_keys; then
	echo $i >> global_keys
	fi
done
#Above for loop iterates over values in $keyslocal and if the value is not in global_keys it is appended to global_keys

count=$(cat < in_pipe)
#Above line reads the key count sent from the distant job_master and stores in the variable count
	
echo "received" > out_pipe
#Signal distant job_master that keys have been received

count_check=0
while [ $count_check -lt $count ]; do
	keysdistant=$(cat < in_pipe)
	for i in $keysdistant; do
		if ! grep -q "$i" global_keys; then
		echo $i >> global_keys
		fi
		((count_check=count_check+1))
		echo $count_check	
	done
done
#Above while loop will receive the keys from the distant job_master and exit the while loop once the full count of keys has been received

if [ ! -e new_keys ]; then #create new_keys file if it doesn't exist
	touch new_keys
fi

if [ ! -e send_keys ]; then #create send_keys file if it desn't exist
	touch send_keys
fi

glob=$(cat global_keys) #read file global_keys and store value in variable $glob

count_glob=1
for i in $glob; do
	if ! ((count_glob % 2)); then
		if ! grep -q "$i" new_keys; then
			echo $i >> new_keys
		fi
	else 
		echo $i > out_pipe
		if ! grep -q "$i" send_keys; then
			echo $i >> send_keys
		fi
	fi
	((count_glob=count_glob+1))
done
#Above for loop iterates over values on $glob and will send even numbered keys to new_keys file - to be processed by local job_master
#and will send odd numbered keys to send_keys - to be sent to and processed by distant job_master
echo "sent" > local_pipe #signal local job_master that keys files have been created
echo "sent" > out_pipe #signal distant job_master that keys files have been created and all keys have been sent

read i < in_pipe #block until message received from distant job_master that all keys have been saved
echo "hey there"
#test
testcount=0
send_keys=$(cat < send_keys)
for i in $send_keys; do
	file=$(cat < $i)
	append=""
	for j in $file; do
	append="$append $i"
	done
	echo $append > out_pipe
	#for j in $file; do
	#	echo $j > out_pipe
	#	sleep 0.01 #connection will break without this sleep
	#done
done

#Above for loop will open the file corresponding to each key in send_keys and send the contents of these to the distant job_master line by line

echo "done" > out_pipe #Signl distant job_master that all key/value pairs have been sent

read input < in_pipe #wait for signal that files have been received by distant job master

new_keys=$(cat < new_keys) #read contents of new_keys file to find out which files need to be sent from distant machine

for i in $new_keys; do
	echo $i > out_pipe #send values in new_keys to distant machine
done

echo "done" > out_pipe #signal distant machine that all values sent

read input < in_pipe
sent="no"
while [ "$sent" != "done" ]; do
	sent_keys=$(cat < in_pipe)
	for i in $sent_keys; do
		#echo $i
		if [ "$i" != "done" ]; then  
			echo $i >> "$i"
		elif [ "$i" = "done" ]; then
			sent="done"
		fi
	done
done
#Above while loop wil read values sent by distant job_master and append to file of corresponding name until signal that all values sent received
echo "ready" > out_pipe #signal distant job_master that values have been saved
echo "ready" > local_pipe #signal local job_master that key values are ready to be counted

read input < in_pipe #Block until signal that distant job_master is finished received
echo $input

if [ "$input" = "finished" ]; then #terminate script
	killall echo_local.sh
	killall master12751005.sh
fi

