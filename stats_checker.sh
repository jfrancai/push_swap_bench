# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    stats_checker.sh                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jfrancai <jfrancai@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2022/02/10 17:01:43 by jfrancai          #+#    #+#              #
#    Updated: 2022/02/11 10:56:43 by jfrancai         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!bash

# Change args here
FILE="tmp"
# Benchmark size when --stats is use
SET_LEN=100
MIN=1
MAX=500
# Random number generator (use your own list if your prefer to)
ARG=`ruby -e "puts ($MIN..$MAX).to_a.shuffle.join(' ')"`

OP="./push_swap $ARG"
CHECKER="./checker_linux $ARG"

# Defaults
if [[ $# -eq 0 ]]
then
	echo "Checker : $($OP | $CHECKER)"
	exit 0;
fi

med () {
	len=$(cat $FILE | wc -l)
	MED=$(cat $FILE | sort -n | head -n $(((len+1)/2)) | tail -n 1)
}

range () {
	MINVAL=$(cat $FILE | sort -n | head -n 1)
	MAXVAL=$(cat $FILE | sort -n | tail -n 1)
}

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
		printf "mean=" M
		printf "   std.dev=" sqrt(var);
	}' <<< $foo);
}

# Flags available (--stats make a benchmark of your push_swap | -v shoes you the actual moves of your algo (debug tool maybe ?))
case "$1" in
-a|--args)
	echo $ARG
	echo "Checker : $($OP | $CHECKER)";;
--stats)
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
	echo -e	"\n\n"
	;;
-v|--verbose)
		VERBOSE=1
	echo $ARG
	$OP
	echo "Checker : $($OP | $CHECKER)";;
esac
