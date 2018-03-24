#! /bin/bash
list=$(cut -d"," -f$2 $1) #read second field in file given as first argument using comma as delimiter and store in $list

for i in $list; do #iterate over values in list
	if [ ! -e "$i" ];then #critical section is nested to avoid using semaphores on every iteration of for loop
		echo "$i" >> "$i" #write element name to file
		echo $i > map_pipe #echo unique element to map_pipe
	else
		echo "$i" >> "$i" #append current element in list to file of same name
	fi
done

echo "finished" > map_pipe #let job_master know map is finished

