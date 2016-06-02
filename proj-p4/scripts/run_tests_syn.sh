#!/bin/sh

HOMEDIR=`pwd`
echo $HOMEDIR

TESTFILES=${HOMEDIR}/testfiles

echo "GOLD CMP TESTING BEGIN"

# Create a log directory to store results
rm -rf logs/
mkdir -p logs/

make clean
make TOP=tb_gold_cmp_syn >> logs/runs.log

# Test Each Instruction Stream
for num in {0..100}
do
	echo "RUNNNIG TEST # ${num}" 
	# Use correct dmem.fill file 
	if [ $num -eq 0 ]; then
		cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.0.fill
		cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.1.fill
		cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.2.fill
		cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.3.fill
		echo "Using dmem_bkup.fill file"
	fi
	if [ $num -eq 100 ]; then
		cp ${TESTFILES}/dmem_br.fill cmp_test.dmem.0.fill
		cp ${TESTFILES}/dmem_br.fill cmp_test.dmem.1.fill
		cp ${TESTFILES}/dmem_br.fill cmp_test.dmem.2.fill
		cp ${TESTFILES}/dmem_br.fill cmp_test.dmem.3.fill
		echo "Using dmem_br.fill file"
    fi

	# Copy over imem_<val>.fill to imem.fill
	cp ${TESTFILES}/imem_${num}.fill cmp_test.imem.0.fill
	cp ${TESTFILES}/imem_${num}.fill cmp_test.imem.1.fill
	cp ${TESTFILES}/imem_${num}.fill cmp_test.imem.2.fill
	cp ${TESTFILES}/imem_${num}.fill cmp_test.imem.3.fill
	
	# Simulate
	make run TOP=tb_gold_cmp_syn >> logs/runs.log
	
	# Copy generated dump file to logs/
	cp cmp_test.dmem.0.dump logs/cmp_test.dmem.0_${num}.dump
    echo "diff   --ignore-all-space logs/cmp_test.dmem.0_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump" >> logs/diff.txt
    diff --brief --ignore-all-space logs/cmp_test.dmem.0_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
    diff         --ignore-all-space logs/cmp_test.dmem.0_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
	
	# Copy generated dump file to logs/
	cp cmp_test.dmem.1.dump logs/cmp_test.dmem.1_${num}.dump
    echo "diff   --ignore-all-space logs/cmp_test.dmem.1_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump" >> logs/diff.txt
    diff --brief --ignore-all-space logs/cmp_test.dmem.1_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
    diff         --ignore-all-space logs/cmp_test.dmem.1_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
	
	# Copy generated dump file to logs/
	cp cmp_test.dmem.2.dump logs/cmp_test.dmem.2_${num}.dump
    echo "diff   --ignore-all-space logs/cmp_test.dmem.2_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump" >> logs/diff.txt
    diff --brief --ignore-all-space logs/cmp_test.dmem.2_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
    diff         --ignore-all-space logs/cmp_test.dmem.2_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
	
	# Copy generated dump file to logs/
	cp cmp_test.dmem.3.dump logs/cmp_test.dmem.3_${num}.dump
    echo "diff   --ignore-all-space logs/cmp_test.dmem.3_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump" >> logs/diff.txt
    diff --brief --ignore-all-space logs/cmp_test.dmem.3_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
    diff         --ignore-all-space logs/cmp_test.dmem.3_${num}.dump ${TESTFILES}/expected_dmem_${num}.dump >> logs/diff.txt
	
done

make clean
rm -f dmem.dump
cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.0.fill
cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.1.fill
cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.2.fill
cp ${TESTFILES}/dmem_bkup.fill cmp_test.dmem.3.fill
	
echo "GOLD CMP TESTING ENDS"
echo ""
echo ""
