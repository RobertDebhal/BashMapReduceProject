while true; do
	read x
	#length=${#x}
	# above gets length of string. taken from: stackoverflow/questions/17368067/length-of-string-in-bash
	# was having issues with blank values being echoed to pipe when connection severed so checked for string length
	#sleep 1
	#if [ $length -gt 0 ]; then
	#for i in $x; do
	echo $x > in_pipe
	#done
	#fi
done
