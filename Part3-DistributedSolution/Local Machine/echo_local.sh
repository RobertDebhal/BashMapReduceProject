#! /bin/bash
while true; do
	input=$(cat < out_pipe)
	#for i in $input; do
		echo $input 
		sleep 0.05 
	#done
done
