#!/bin/tcsh

# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download

#==========================================================================
# This script removes assimilation output from $DOUT_S_ROOT ($local_archive) after:
# 1) it has been repackaged by repack_st_archive.csh,
# 2) globus has finished moving files to data_campaign storage.,
# 3) other output has been left behind by all of those processes (i.e in rundir).
# >>> Check all final archive locations for complete sets of files
#     before running this.  <<<
#     This can be done by using ./pre_purge.csh, 
#     or see "Look in" below.
# Submit from $CASEROOT.

#-----------------------------------------

if (! -f CaseStatus) then
   echo "ERROR: this script must be run from the CESM CASEROOT directory"
   exit 1
endif

#--------------------------------------------
# Default values of which file sets to purge.
set do_forcing     = 'true'
set do_restarts    = 'true'
set do_history     = 'true'
set do_state_space = 'true'
set do_rundir      = 'true'

# "components" = generic pieces of CESM (used in the archive directory names).
# "models" = component instance names (models, used in file names).
set components     = (lnd  atm ice  rof)
set models         = (clm2 cam cice mosart)


if ($#argv != 0) then
   # Request for help; any argument will do.
   echo "Usage:  "
   echo "Before running this script"
   echo "    Run repack_st_archive.csh. "
   echo "    Confirm that it put all the output where it belongs using pre_purge_check.csh. "
   echo "    Edit this script to be sure that your desired "
   echo "    file types and model/components will be purged."
   echo "    DO NOT RUN THIS SCRIPT IF THE rpointer FILES REFER TO A DATE"
   echo "    WHICH IS >= 2 MONTHS AHEAD OF THE DATES TO BE PURGED"
   echo "    If they are, make this script reference a different data_scripts.csh."
   echo "Call by user or script:"
   echo "   purge.csh "
   exit
endif

# Get CASE environment variables from the central variables file.
source ./data_scripts.csh
echo "data_CASE  = ${data_CASE}"
echo "data_year  = ${data_year}"
echo "data_month = ${data_month}"

set yr_mo = `printf %4d-%02d ${data_year} ${data_month}`
set local_arch     = `./xmlquery DOUT_S_ROOT --value`

#--------------------------------------------

set lists = logs/rm_${yr_mo}.lists
if (-f ${lists}.gz) mv ${lists}.gz ${lists}.gz.$$
pwd > $lists

#------------------------
# Purge the "forcing" files (cpl history) that came from individual members at single times.
# These have been appended to the yearly files for archiving.
if ($do_forcing == true) then
   cd ${local_arch}/cpl/hist
   pwd >>& ${local_arch}/$lists

   # The original cpl hist (forcing) files,
   # which have been repackaged into $data_proj_space.
   foreach type (ha2x3h ha2x1h ha2x1hi ha2x1d hr2x)
      echo "Forcing $type" >>& ${local_arch}/$lists
      # ls ${data_CASE}.cpl_*.${type}.${yr_mo}-*.nc >>& ${local_arch}/$lists
      rm -v ${data_CASE}.cpl_*.${type}.${yr_mo}-*.nc >>& ${local_arch}/$lists
   end

   echo "Forcing \*.eo" >>& ${local_arch}/$lists
   # ls *.eo >>& ${local_arch}/$lists
   rm -v *.eo >>& ${local_arch}/$lists

   cd ${local_arch}
endif

#------------------------
# Purge the restart file sets which have been archived to Campaign Storage.
# The original ${yr_mo}-DD-SSSSS directories were removed by repack_st_archive
# when the tar (into "all types per member") succeeded.
# The following ${yr_mo} directories have been archived to Campaign Storage.
if ($do_restarts == true) then
   echo "Restarts starts at "`date`
   cd ${local_arch}/rest
   pwd >>& ${local_arch}/$lists

   echo "Restarts ${yr_mo}\*" >>& ${local_arch}/$lists
   rm -rfv ${yr_mo}* >>& ${local_arch}/$lists

   # Remove other detritus
   echo "Restarts tar\*.eo" >>& ${local_arch}/$lists
   rm -v tar*.eo >>& ${local_arch}/$lists

   cd ${local_arch}
endif

#------------------------
# Purge component history files (.h[0-9]), 
# which have been tarred into monthly files for each member.
# E.g. {lnd,atm,ice,rof}/hist/0080/*.{clm2,cam,cice,mosart}_*.h*[cz]

if ($do_history == true) then
   set m = 1
   while ($m <= $#components)
      cd ${local_arch}/$components[$m]/hist
      pwd >>& ${local_arch}/$lists
      @ type = 0
      while ($type < 10)
         echo "$components[$m] type $type" >>& ${local_arch}/$lists
         ls ${data_CASE}.$models[$m]_0001.h${type}.${yr_mo}-*.nc > /dev/null
         if ($status != 0) break

         rm -v ${data_CASE}.$models[$m]_*.h${type}.${yr_mo}-*.nc >>& ${local_arch}/$lists
         @ type++
      end
   
      cd ${local_arch}
      @ m++
   end
endif


#------------------------
# Purge the directories in $DOUT_S_ROOT (scratch ...)
# which have been archived to Campaign Storage.

if ($do_state_space == true) then
   cd ${local_arch}/esp/hist
   pwd >>& ${local_arch}/$lists
   rm -rfv $yr_mo   >>& ${local_arch}/$lists

   cd ${local_arch}/atm/hist
   pwd >>& ${local_arch}/$lists
   rm -rfv $yr_mo   >>& ${local_arch}/$lists
   
   # Archive DART log files (and others?)

   cd ${local_arch}/logs
   # This looks misdirected at first, but $lists has 'logs/' in it.
   pwd >>& ${local_arch}/$lists
   rm -rfv $yr_mo >>& ${local_arch}/$lists
   rm -rfv {atm,cpl,ice,lnd,ocn,rof}_00[0-9][02-9].log.*
   
   cd ${local_arch}

endif

#------------------------
# Purge leftover junk in $RUNDIR (scratch ...)
if ($do_rundir == true) then
   cd ${local_arch}/../run
   pwd >>& ${local_arch}/$lists

   # Remove old inflation restarts that were archived elsewhere
   # and were copied back into rundir by assimilate.csh.
   set files = `ls -t ${data_CASE}.dart.rh.cam_output_priorinf_sd.${yr_mo}*`
   # Skip the most recent.  
   # (The beginning of the next month isn't even in the list.)
   set d = 2
   while ($d <= $#files)
      set date = $files[$d]:r:e
      echo "${data_CASE}.dart.rh.cam*.${date}.*" >>& ${local_arch}/$lists
      rm -v ${data_CASE}.dart.rh.cam*.${date}.* >>& ${local_arch}/$lists
      @ d++
   end

   # Remove less-than-useful cam_dart_log.${yr_mo}-*.out   
   set files = `ls -t cam_dart_log.${yr_mo}*.out`
   rm -v $files[2-$#files] >>& ${local_arch}/$lists

   ls finidat_interp_dest_* >& /dev/null
   if ($status == 0) then
      rm -v finidat_interp_dest_* >>& ${local_arch}/$lists
   endif

   cd ${local_arch}
endif
#------------------------

cd archive
gzip $lists

# Wait for all the backrounded 'rm's to finish.
wait

exit 0
