#! /bin/bash
start=$(date +%s)
list=$(cut -d"," -f2 $1)
echo $$ $1
count=0
for i in $list; do
	#./P.sh lock
	if [ ! -e "$i" ]; 
	then	
		#./P.sh
		#if [ ! -e "$i" ];
		#then
			touch $i
			echo "$i" >> $i
			echo $i > map_pipe
		#else
		#	echo "$i" >> $i
		#fi
		#./V.sh
	else
	echo "$i" >> $i
	fi
	#echo $i > map_pipe
	#./V.sh lock
	done
echo "$1 finished"
echo "finished" > map_pipe
