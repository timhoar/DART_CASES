#!/bin/tcsh
# Script to change the run type to 'branch'
# so that a new history file (CLM) set can be started.
# This does NOT change the case name.

./xmlchange RUN_TYPE=branch
./xmlchange CONTINUE_RUN=FALSE
./xmlchange RUN_REFCASE=f.e21.FHIST_BGC.f09_025.CAM6assim.011
./xmlchange RUN_REFDIR=/glade/scratch/raeder/f.e21.FHIST_BGC.f09_025.CAM6assim.011/run
./xmlchange RUN_REFDATE=2012-01-01

./xmlchange DATA_ASSIMILATION_CYCLES=1
./xmlchange RESUBMIT=0

# Don't need
# ./xmlchange GET_REFCASE=TRUE   because the files are already in the rundir.
# ./xmlchange START_TOD=$start_tod   it's already 0.

