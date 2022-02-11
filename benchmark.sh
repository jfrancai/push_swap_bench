# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    benchmark.sh                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jfrancai <jfrancai@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2022/02/11 12:23:37 by jfrancai          #+#    #+#              #
#    Updated: 2022/02/11 12:24:47 by jfrancai         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

# Configuration
#-----------------------------------------------------------------------------

# Benchmark size when --stats flag is used
# Complexity will be : SET_LEN * complex.of.your.push_swap_algo
# Try with small value at first
SET_LEN=1000

# Random number generator (use your own list if your prefer to)
# For this one you should make sure that ruby is install on your machin
MIN=1
MAX=5
ARG=`ruby -e "puts ($MIN..$MAX).to_a.shuffle.join(' ')"`

# Execute the following bin with ARG as param
OP="./push_swap $ARG"

# Change for checker_Mac if needed
CHECKER="./checker_linux $ARG"

# Temp file where bench results are saved (if you don't know if you should change it, do not)
FILE="tmp"

#-----------------------------------------------------------------------------


# If there is no flag :
# Uses your checker on your push_swap bin and return status check
if [[ $# -eq 0 ]]
then
	echo "Checker : $($OP | $CHECKER)"
	exit 0;
fi

# The design was meant to be use with only one flag at a time (feel free to fork and change this behavior)
if [[ $# -gt 1 ]]
then
	echo "Only one flag should be used."
	exit 0
fi

# Calculates median
med () {
	len=$(cat $FILE | wc -l)
	MED=$(cat $FILE | sort -n | head -n $(((len+1)/2)) | tail -n 1)
}

# Calculates min and max
range () {
	MINVAL=$(cat $FILE | sort -n | head -n 1)
	MAXVAL=$(cat $FILE | sort -n | tail -n 1)
}

# Calculates average cost and standard deviation
# Credit : @pbot (https://stackoverflow.com/a/32728191/13916430)
stats () {
	foo=$(cat $FILE | tr "\n" " ")
	STATS=$(awk '{
		M = 0;
		S = 0;
		for (k=1; k <= NF; k++) {
			x = $k;
			oldM = M;
			M = M + ((x - M)/k);
			S = S + (x - M)*(x - oldM);
		}
		var = S/(NF-1);
		printf "avg=" M "   std.dev=" sqrt(var);
	}' <<< $foo);
}

# Flags : 
# -s | --stats   : makes a benchmark of your push_swap
# -a | --args    : show args of your push_swap 
# -v | --verbose : debug tool

case "$1" in
-a|--args)
	echo $ARG
	echo "Checker : $($OP | $CHECKER)";;
-s|--stats)
	echo "processing... Please wait."
	rm -rf $FILE
	for (( i=0; i<$SET_LEN; i++))
	do
		ARG=`ruby -e "puts ($MIN..$MAX).to_a.shuffle.join(' ')"`
		OP="./push_swap $ARG"
		WC=$($OP | wc -l)
		echo $WC >> $FILE
	done;
	med;range;stats	
	echo -e "o----------------------------------------------------------------------o"
	echo -e	"|                                                                      |"
	echo -e	"|                               Benchmark                              |"
	echo -e	"|                                                                      |"
	echo -e	"o----------------------------------------------------------------------o"
	echo -e	"\n"
	echo -e	"     med=$MED   min=$MINVAL   max=$MAXVAL   $STATS"
	echo -e	"\n\n";;
-v|--verbose)
	echo $ARG
	$OP
	echo "Checker : $($OP | $CHECKER)";;
*)
	echo "available flags : --args --verbose --stats"
	;;
esac
