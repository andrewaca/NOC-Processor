set modname gold_cmp
set topmetal 10
set holdslack 0.15

setUIVar rda_Input ui_gndnet gnd
setUIVar rda_Input ui_timingcon_file sdc/gold_cmp_pnr1.sdc
setUIVar rda_Input ui_leffile ../../../../scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.lef
setUIVar rda_Input ui_timelib ../../../../scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.tlf
setUIVar rda_Input ui_netlist netlist/gold_cmp.syn.v
setUIVar rda_Input ui_topcell gold_cmp
setUIVar rda_Input ui_pwrnet vdd
commitConfig
fit
setDrawView fplan
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site CoreSite -r 0.996359643646 0.700041 20 20 20 20
uiSetTool select
getIoFlowFlag
fit
clearGlobalNets
globalNetConnect vdd -type pgpin -pin vdd -inst * -module {}
globalNetConnect gnd -type pgpin -pin gnd -inst * -module {}
addRing -spacing_bottom 4 -width_left 4 -width_bottom 4 -width_top 4 -spacing_top 4 -layer_bottom metal9 -stacked_via_top_layer metal10 -width_right 4 -around core -jog_distance 0.855 -offset_bottom 4 -layer_top metal9 -threshold 0.855 -offset_left 4 -spacing_right 4 -spacing_left 4 -offset_right 4 -offset_top 4 -layer_right metal10 -nets {gnd vdd } -stacked_via_bottom_layer metal1 -layer_left metal10

addStripe -block_ring_top_layer_limit metal10 -max_same_layer_jog_length 1.6 -padcore_ring_bottom_layer_limit metal9 -number_of_sets 8 -stacked_via_top_layer metal10 -padcore_ring_top_layer_limit metal10 -spacing 4 -xleft_offset 110 -xright_offset 110 -merge_stripes_value 0.855 -layer metal10 -block_ring_bottom_layer_limit metal9 -width 4 -nets {gnd vdd } -stacked_via_bottom_layer metal1

sroute -connect { blockPin padPin corePin floatingStripe } -layerChangeRange { 1 10 } -blockPinTarget { nearestRingStripe nearestTarget } -padPinPortConnect { allPort oneGeom } -checkAlignedSecondaryPin 1 -blockPin useLef -allowJogging 1 -crossoverViaBottomLayer 1 -allowLayerChange 1 -targetViaTopLayer 10 -crossoverViaTopLayer 10 -targetViaBottomLayer 1 -nets { gnd vdd }
saveDesign ./${modname}_power.enc -compress

setReleaseMultiCpuLicense 0
setMultiCpuUsage -numThreads max -numHosts 1 -superThreadsNumThreads max -superThreadsNumHosts 1

setPlaceMode -congEffort high
setPlaceMode -modulePlan true
setPlaceMode -maxDensity 0.70
setOptMode -maxDensity 0.7
setOptMode -holdTargetSlack $holdslack

placeDesign -inPlaceOpt

optDesign -preCTS

unloadTimingCon
loadTimingCon sdc/gold_cmp_pnr2.sdc

clearClockDomains
setClockDomains -all
timeDesign -preCTS -idealClock -pathReports -drvReports -slackReports -numPaths 50 -prefix gold_cmp_preCTS -outDir timingReports
clearClockDomains
setClockDomains -all
timeDesign -preCTS -hold -idealClock -pathReports -slackReports -numPaths 50 -prefix gold_cmp_preCTS -outDir timingReports

saveDesign ./${modname}_prects.enc -compress
