#!/bin/bash
let average=0
sleep 10
for a in {0..2}
do
	rm timing.txt
	touch timing.txt
	timing=()
	for i in {0..9}
	do
		/usr/bin/time --quiet --o=timing.txt --a -f"%E" ./target/release/rust example.txt 30 > /dev/null
	done
	while IFS= read -r line
	do
		lineNumber="${line//.}"
		lineNumber="${lineNumber//:}"
		lineNumber="${lineNumber:3:2}"
		timing+=( $lineNumber )
	done < "timing.txt"
	echo "${timing[*]}"
	timingSum=0
	for x in {0..9}
	do
		let "timingSum+=${timing[x]}"
	done
	echo "Timing Sum: $timingSum"
	let timingAvg=$timingSum/10
	echo "Timing Average: $timingAvg"
	Average=$((timingAvg+Average))
done
echo $Average
let averageYes=$((Average/3))
echo "Done, Average: 0.$((averageYes))s"
