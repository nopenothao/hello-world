#!/bin/bash

SOURCE=$1
TRANSLATED=$2
TARGET=$3

#Check if parameter was given
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
    echo "ERROR: Please call '$0 <SOURCE_FILE> <TRANSLATED_FILE> <TARGET_FILE>' to run this script!"
    exit 1
fi
#Check if the source or target file exist
if [ ! -f $1 ] || [ ! -f $2 ]; then
	echo "ERROR: Source or Translated file doesn't exist"
	exit
fi
#Check if the Targe file already exist
if [[ -f $3 ]]; then
	echo "ERROR: Target file already exist"
	exit
fi
#Reads the file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
	printf .
	#First two if statesments are for the lines that doesnt require comparison
	if [[ $line == "<trans-unit*" ]] || [[ $line == "</trans-unit*" ]]; then
		echo "$line" > $TARGET
	elif [[ $line != "<source>"*"</source>" ]] && [[ $line != "<target>"*"</target>" ]]; then
		echo "$line" >> $TARGET
	#if the translation exist it will pull it from TRANSLATED file
	elif grep -q "$line" $TRANSLATED && [[ $line == "<source>"*"</source>" ]]; then
		cat $TRANSLATED | grep "$line" -A 1 -s -m 1 >> $TARGET
	#if the translation does not exist it will pull the SOURCE file instead
	elif ! grep -q "$line" $TRANSLATED && [[ $line == "<source>"*"</source>" ]]; then
		cat $SOURCE | grep -a "$line" -A 1 -s -m 1 >> $TARGET
	fi
done < "$SOURCE"
printf done