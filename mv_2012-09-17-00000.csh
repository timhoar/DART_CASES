#!/bin/tcsh

set MOVE = '/usr/bin/mv -v'
set CASE = f.e21.FHIST_BGC.f09_025.CAM6assim.011
set day_time  = 17-00000
set save_root = /glade/scratch/raeder/${CASE}/archive/rest/2012-09-17-00000
   
${MOVE} ${CASE}*.{r,rs,rs1,rh[0-9]}.*${day_time}*  $save_root 
${MOVE} ${CASE}*.i.[0-9]*${day_time}*             $save_root 
${MOVE} *output*inf*${day_time}*                  $save_root 

# set log_list = `${LIST} -t cesm.log.*`
# set rm_log = `echo $log_list[3] | sed -e "s/\./ /g;"`
# set rm_slot = $#rm_log
# These log files appear to not exist any more: 191015-062614
# (${MOVE} *0001*${rm_log[$rm_slot]}*                $save_root || exit 63) &
# Do manually
# (${MOVE} cesm*${rm_log[$rm_slot]}*                 $save_root || exit 64) &
