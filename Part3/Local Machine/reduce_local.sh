#! /bin/bash
product=$(cat $1)
count=0
for i in $product; do
	((count=count+1))
done

echo "$1 $count" > reduce_pipe

echo "finished" > reduce_pipe
