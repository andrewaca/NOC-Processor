#!/bin/sh

grep -oP '(?<=Total cell area:).*' *.area >> results.txt
grep "slack" *.timing >> results.txt
sort results.txt > results_sort.txt
sed -i 's/(VIOLATED)//g' results_sort.txt
sed -i 's/slack//g' results_sort.txt
sed -i 's/(MET)//g' results_sort.txt
sed -i 's/  */ /g' results_sort.txt
sed -i 's/}.area: /,/g' results_sort.txt
sed -i 's/}.timing: /,,/g' results_sort.txt
sed -i 's/gold_cmp.{//g' results_sort.txt
sed -i '1s/^/Period,Area,Slack\n/' results_sort.txt
mv results_sort.txt results.csv
unix2dos results.csv
