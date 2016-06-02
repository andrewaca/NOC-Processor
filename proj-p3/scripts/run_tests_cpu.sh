#!/bin/sh

HOMEDIR=`pwd`
echo $HOMEDIR

TESTFILES=${HOMEDIR}/testfiles

echo "GOLD PROCESSOR TESTING BEGIN"

# Create a log directory to store results
rm -rf logs/
mkdir -p logs/

make clean
make TOP=cpu_tb >> logs/runs.log

# Test Each Instruction Stream
for num in {0..100}
do
	echo "RUNNNIG TEST # ${num}" 
	# Use correct dmem.fill file 
	if [ $num -eq 0 ]; then
		cp ${TESTFILES}/dmem_bkup.fill dmem.fill
		echo "Using dmem_bkup.fill file"
	fi
	if [ $num -eq 100 ]; then
		cp ${TESTFILES}/dmem_br.fill dmem.fill
		echo "Using dmem_br.fill file"
    fi

	# Copy over imem_<val>.fill to imem.fill
	cp ${TESTFILES}/imem_${num}.fill imem.fill
	
	# Simulate
	make run TOP=cpu_tb >> logs/runs.log
	
	# Copy generated dump file to logs/
	cp dmem.dump logs/dmem_${num}.dump
	
    echo "diff --ignore-all-space logs/dmem_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump" >> logs/diff.txt
    diff --brief --ignore-all-space logs/dmem_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
    diff --ignore-all-space logs/dmem_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
	
done

make clean
rm -f dmem.dump
cp ${TESTFILES}/dmem_bkup.fill dmem.fill
	
echo "GOLD PROCESSOR TESTING ENDS"
echo ""
echo ""
