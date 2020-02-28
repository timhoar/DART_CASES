#!/bin/csh -f

# This script defines data/arguments/parameters
# used by many non-CESM scripts in the workflow.

setenv  data_NINST            80
setenv  data_proj_space       /glade/p/nsc/ncis0006/Reanalyses
setenv  data_DART_src         /glade/u/home/raeder/DART/reanalysis_git
setenv  data_CASEROOT         /glade/work/raeder/Exp/f.e21.FHIST_BGC.f09_025.CAM6assim.011
setenv  data_CASE             f.e21.FHIST_BGC.f09_025.CAM6assim.011
setenv  data_scratch          /glade/scratch/raeder/f.e21.FHIST_BGC.f09_025.CAM6assim.011
setenv  data_campaign         /gpfs/csfs1/cisl/dares/Reanalyses
setenv  data_CESM_python      /glade/work/raeder/Models/cesm2_1_relsd_m5.6/cime/scripts/lib/CIME 
setenv  data_DOUT_S_ROOT      /glade/scratch/raeder/f.e21.FHIST_BGC.f09_025.CAM6assim.011/archive

setenv CONTINUE_RUN `./xlmquery CONTINUE_RUN --value`
if ($CONTINUE_RUN == FALSE) then
   set START_DATE = `./xlmquery RUN_START_DATE --value`
   set parts = `echo $START_DATE | sed -e "s#-# #"`
   setenv data_year $parts[1]
   setenv data_month $parts[2]

else if ($CONTINUE_RUN == TRUE) then
   # Get date from an rpointer file
   if (! -f ${data_scratch}/run/rpointer.atm_0001) then
      echo "CONTINUE_RUN = TRUE but "
      echo "${data_scratch}/run/rpointer.atm_0001 is missing.  Exiting"
      exit 19
   endif
   set FILE = `head -n 1 ${data_scratch}/run/rpointer.atm_0001`
   set ATM_DATE_EXT = $FILE:e
   set ATM_DATE     = `echo $ATM_DATE_EXT | sed -e "s#-# #g"`
   setenv data_year   `echo $ATM_DATE[1] | bc`
   setenv data_month  `echo $ATM_DATE[2] | bc`

else
   echo "env_run.xml: CONTINUE_RUN must be FALSE or TRUE (case sensitive)"
   exit

endif

