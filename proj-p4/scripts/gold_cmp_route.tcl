set modname gold_cmp
set topmetal 10
set holdslack 0.15

restoreDesign ./${modname}_cts_opt.enc.dat gold_cmp

unloadTimingCon
loadTimingCon sdc/gold_cmp_pnr4.sdc

setNanoRouteMode -quiet -routeBottomRoutingLayer 0
setNanoRouteMode -quiet -routeTopRoutingLayer $topmetal
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeTdrEffort 10
setNanoRouteMode -quiet -routeWithSiDriven false

setReleaseMultiCpuLicense 0
setMultiCpuUsage -numThreads max -numHosts 1 -superThreadsNumThreads max -superThreadsNumHosts 1

routeDesign -globalDetail -wireOpt

setOptMode -holdTargetSlack $holdslack
optDesign -postRoute
optDesign -postRoute -hold

checkplace
checkroute
verifyGeometry
verifyConnectivity -type all

clearClockDomains
setClockDomains -all
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix gold_cmp_postRoute -outDir timingReports
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix gold_cmp_postRoute -outDir timingReports

isExtractRCModeSignoff
extractRC
# rcOut -spf gold_cmp.spf
# rcOut -spef gold_cmp.spef
# wireload -outfile gold_cmp.wl -percent 1.0 -cellLimit 100
delayCal -sdf gold_cmp_pnr.sdf
saveNetlist netlist/gold_cmp.pnr.v
summaryReport -noHtml -outfile reports/pnrReport.txt

saveDesign ./${modname}_routed.enc -compress
