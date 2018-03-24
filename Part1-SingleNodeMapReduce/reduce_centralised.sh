#! /bin/bash
product=$(cat $1) #read the file given as first argument and store in $product variable
count=0 #initialise count variable with value 0
for i in $product; do #iterate over values in $product
	((count=count+1)) #increment count by 1 for each value in $product
done

echo "$1 $count" > reduce_pipe #echo the count to the reduce_pipe

echo "finished" > reduce_pipe #let job_master.sh know reduce is finished
