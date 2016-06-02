###########################################################################
# This is a general purpose makefile to compile and run                   #
# Cadence NCSIM simulations                                               #
#                                                                         #
# To compile                                                              #
# ----------                                                              #
# %> make                                                                 #
#                                                                         #
# To run simulation in console mode                                       #
# ---------------------------------                                       #
# %> make sim                                                             #
#                                                                         #
# To run simulation in gui mode                                           #
# -----------------------------                                           #
# %> make simg                                                            #
# TO use another TOP module name via commandline, you can use             #
# make TOP=<NewTopModuleName> sim                                         #
# make TOP=<NewTopModuleName> simg                                        #
#                                                                         #
# Directory Stucture                                                      #
# ------------------                                                      #
# This makefile assumes the following directory structure :               #
#                                                                         #
# ./        -- current directory, simulation is going to run from here    #
# ./work    -- Cadence work library to compile the design                 #
# ./design  -- holds all design verilog files                             #
# ./tb      -- holds testbench file(s)                                    #
# ./netlist -- netlists generated from synthesis/Place Route              #
# ./include -- files included in the verilog files using include command  #
# ./scripts -- holds tcl run scripts for simulation control               #
# ./reports -- holds all the reports from simulation                      #
#                                                                         #
# To Create the initial directory structure necessary for the HW4/project #
# %> make init							          #
#                                                                         #
# To prepare tar-file for submission                                      #
# Make sure you add names to AUTHORS file before                          #
# %> make submit                                                          #
# After submission is created you can test tar-ball with                  #
# tar tvf <filename>.tar                                                  #
# it will list all files included in the tar-ball                         #
#                                                                         #
###########################################################################
#                                                                          
# Setup environment variables to point the Cadence instal directories      
# and license files etc                                                      
# source ~ee577/vlsi_tools.csh                                              

author1 :=$(shell awk 'NR==1 {print $$1; exit}' AUTHORS)
author2 :=$(shell awk 'NR==2 {print $$1; exit}' AUTHORS)

ifdef author1
 filename=${author1}
endif

ifdef author2
 filename = ${author1}_${author2}
endif

ifndef filename
 filename := $(shell whoami)
endif

# Team Name Here
# For example
# TEAMNAME = trojan
TEAMNAME = JHH

# top level module
TOP = tb_gold_cmp_syn

# List of the design files
DESIGN_FILES = ./design/*.v

# List of the testbench files
TB_FILES = ./tb/*.v

INCLUDE_DIRECTORY = ./include

# GUI simulation script file
SIM_SCRIPT_FILE_GUI = ./scripts/runscript.tcl

# Non GUI simulation script file
SIM_SCRIPT_FILE_NO_GUI = ./scripts/runscript_nogui.tcl

# ncvlog switch 
NCVLOG_SWITCHES = \
	-64BIT \
	-STATUS \
	-UPDATE \
	-MESSAGES \
    -NOCOPYRIGHT \
	-INCDIR $(INCLUDE_DIRECTORY)

#ncelab switches
NCELAB_SWITCHES = \
	-64BIT \
	-MESSAGES \
    -NOCOPYRIGHT \
	-ACCESS +rwc \
	-NCFATAL INVSUP \
	-NCFATAL CUNOTB \
	-ERRORMAX 5 \
	-UPDATE \
	-TIMESCALE '1ns/10ps' \
	-LIBVERBOSE

# ncsim simulation switches for console simulation
NCSIM_SWITCHES_NO_GUI = \
	-64BIT \
	-STATUS \
    -NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_NO_GUI)

# ncsim switches for GUI simulations
NCSIM_SWITCHES_GUI = \
	-64BIT \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_GUI) \
	-GUI

all : elab~

# analyze all the design and testbench files
ana~ : $(DESIGN_FILES)
	for f in $(DESIGN_FILES); do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	#for f in $(TB_FILES);     do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	ncvlog $(NCVLOG_SWITCHES) -work work ./tb/$(TOP).v
	@touch ana~

# elaborate the top module
elab~ : ana~
	ncelab $(NCELAB_SWITCHES) work.$(TOP)
	@touch elab~

# run simulation without gui
sim : clean elab~
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP)

# run simulation with gui
simg : clean elab~
	ncsim $(NCSIM_SWITCHES_GUI) work.$(TOP)

run : 
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP)


# clean the library to have a clean start
clean :
	@rm -rf `find . -name '*~'`
	@rm -rf work waves.shm 
	@rm -rf ncsim*
	@rm -rf *.log
	@rm -f default.svf
	@rm -rf .simvision/
	@mkdir work
	@echo 'All set for a clean start'

# create directory structure
dir :
	@rm -rf work	
	@mkdir work
	@mkdir design tb include scripts netlist sdf reports
	@echo 'Directory structure for simulation is created'

# create the basic cds.lib file
cds.lib :
	@echo 'DEFINE work work' > cds.lib

# create hdl.var
hdl.var :
	@echo '# Hello Cadence' > hdl.var

init : dir cds.lib hdl.var
	@touch AUTHORS
	@echo 'Initialized the directory for simulation'

submit: clean
	@rm -rf ${TEAMNAME}.tar
	@tar cvf ${TEAMNAME}.tar .

