set modname gold_cmp
set topmetal 10
set holdslack 0.15

restoreDesign ./gold_cmp_prects.enc.dat gold_cmp

setReleaseMultiCpuLicense 0
setMultiCpuUsage -numThreads max -numHosts 1 -superThreadsNumThreads max -superThreadsNumHosts 1

addCTSCellList {BUFX2 BUFX4 CLKBUF1 CLKBUF2 CLKBUF3 INVX1 INVX2 INVX4 INVX8}
clockDesign -specFile scripts/Clock.ctstch -outDir clock_report

saveDesign ./${modname}_cts.enc -compress
