#!/bin/bash
filename=$1
if [ $# = 0 ]; then 
	echo "please enter the name of the mpileup file to be analyzed."
	exit
fi
if [ ! -f $filename ]; then
	echo "cannot open file" $1 
	exit
fi
if [ ! -f ../bin/mapgd ]; then
	echo "mapgd cannot be found. Perhaps you haven't run make?"
	exit
fi

./bin/mapgd sam2pro $filename > infile.txt
./bin/mapgd ep -i ./infile.txt -o ./outfile.txt
