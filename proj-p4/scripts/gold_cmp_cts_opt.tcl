set modname gold_cmp
set topmetal 10
set holdslack 0.15

restoreDesign ./gold_cmp_cts.enc.dat gold_cmp

setReleaseMultiCpuLicense 0
setMultiCpuUsage -numThreads max -numHosts 1 -superThreadsNumThreads max -superThreadsNumHosts 1

unloadTimingCon
loadTimingCon sdc/gold_cmp_pnr3.sdc

setOptMode -holdTargetSlack $holdslack
optDesign -postCTS -hold

clearClockDomains
setClockDomains -all
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix gold_cmp_postCTS -outDir timingReports
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix gold_cmp_postCTS -outDir timingReports

saveDesign ./${modname}_cts_opt.enc -compress
