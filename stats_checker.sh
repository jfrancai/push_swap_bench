# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    stats_checker.sh                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jfrancai <jfrancai@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2022/02/10 17:01:43 by jfrancai          #+#    #+#              #
#    Updated: 2022/02/11 09:39:09 by jfrancai         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!bash

# Change args here
FILE="tmp"
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

# Flags available (--stats make a benchmark of your push_swap | -v shoes you the actual moves of your algo (debug tool maybe ?))
case "$1" in
-a|--args)
	echo $ARG
	echo "Checker : $($OP | $CHECKER)";;
--stats)
	echo "processing... Please wait."
	rm -rf $FILE
	for (( i=0; i<10; i++))
	do
		ARG=`ruby -e "puts ($MIN..$MAX).to_a.shuffle.join(' ')"`
		OP="./push_swap $ARG"
		WC=$($OP | wc -l)
		echo $WC >> $FILE
	done
	TMP=$(cat $FILE | tr "\n" " ")
	rm -rf $FILE
	echo $TMP >> $FILE
	sed -i '1s/^/vals /' $FILE
	echo -e "o----------------------------------------------------------------------o\n|                                                                      |\n|                               Benchmark                              |\n|                                                                      |\no----------------------------------------------------------------------o\n";
	awk '{
	NF=11;
	min = max = sum = $2;
	sum2 = $2 * $2
	for (n=3; n <= NF; n++) {
		if ($n < min) min = $n
		if ($n > max) max = $n
		sum += $n;
		sum2 += $n * $n
	}
print "         min=" min "    mean=" sum/(NF-1) "    max=" max "    std.dev=" sqrt(((sum*sum) - sum2)/(NF-1)) "\n";
	}' $FILE;;
-v|--verbose)
		VERBOSE=1
	echo $ARG
	$OP
	echo "Checker : $($OP | $CHECKER)";;
esac
