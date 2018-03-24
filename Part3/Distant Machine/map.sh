#! /bin/bash
start=$(date +%s)
list=`cut -d"," -f2 $1`

for i in $list; do
	if [ ! -e "$i" ];then
		#./P.sh	
		#if [ ! -e "$i" ];
		#then
			touch "$i"
			echo "$i" >> "$i"
			echo $i > map_pipe
		#else
		#	echo "$i" >> "$i"
		#fi
		#./V.sh
	else
		echo "$i" >> "$i"
	fi
done
end=$(date +%s)
runtime=$((end-start))
echo "runtime $runtime"
echo "finished" > map_pipe

