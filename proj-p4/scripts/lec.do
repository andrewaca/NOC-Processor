set log file -replace reports/lec_report1.txt
set parallel option -threads 16

read design /home/scf-36/aadam/ee577b/proj-p4/design/alu.v   /home/scf-36/aadam/ee577b/proj-p4/design/cpu.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_cmp.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_nic.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_ring.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_router.v -Verilog2K -Golden   -sensitive         -continuousassignment Unidirectional   -nokeep_unreach   -nosupply 

read library -Revised -Replace  -sensitive    -Verilog2K /home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.v -nooptimize   

read design /home/scf-36/aadam/ee577b/proj-p4/netlist/gold_cmp.syn.v -Verilog2K -Revised   -sensitive         -continuousassignment Unidirectional   -nokeep_unreach   -nosupply 

uniquify -all -nolibrary

write hier dofile scripts/hier.do -replace -usage -constraint -noexact -run_hier \
-prepend_string "report design data; analyze setup -verbose; usage; \
analyze datapath -module -verbose; usage; \
analyze datapath -verbose; usage"

usage
run hier scripts/hier.do -analyze_abort
usage

//set analyze option -auto
//set system mode lec
//analyze datapath -wordlevel -share -verbose 
//add compared points -all
//compare -NONEQ_Print
//analyze abort -compare