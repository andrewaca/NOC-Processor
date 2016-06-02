set log file -replace reports/lec_report2.txt
set parallel option -threads 16

read design /home/scf-36/aadam/ee577b/proj-p4/design/alu.v   /home/scf-36/aadam/ee577b/proj-p4/design/cpu.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_cmp.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_nic.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_ring.v   /home/scf-36/aadam/ee577b/proj-p4/design/gold_router.v -Verilog2K -Golden   -sensitive         -continuousassignment Unidirectional   -nokeep_unreach   -nosupply 

read library -Revised -Replace  -sensitive    -Verilog2K /home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.v -nooptimize   

read design /home/scf-36/aadam/ee577b/proj-p4/netlist/gold_cmp.syn.v -Verilog2K -Revised   -sensitive         -continuousassignment Unidirectional   -nokeep_unreach   -nosupply 

set system mode lec
add compared points -all
compare -NONEQ_Print -NONEQ_Stop 1