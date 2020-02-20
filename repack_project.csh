#!/bin/tcsh

# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download

# $Id:$

#==========================================================================

# Script to package yearly files found in $project 
# (e.g. /glade/p/nsc/ncis0006/Reanalyses/f.e21.FHIST_BGC.f09_025.CAM6assim.011)
# after repack_st_arch.csh has created them,
# and the matlab scripts have generated the obs space pictures. 
# The resulting files will be moved to 
#   > Campaign Storage for intermediate archiving, 
#     until we want to send them to the RDA.
# This takes time; it actually copies.

# >>> Run repack_st_arch.csh before running this script. <<<
# >>> Log in to globus (see mv_to_campaign.csh for instructions).
# >>> From a casper window (but not 'ssh'ed to data-access.ucar.edu)
#     submit this script from the CESM CASEROOT directory. <<<

# > > > WARNING; cheyenne compute nodes do not have access to Campaign Storage. < < < 
#       Run this on casper using slurm.

#-----------------------------------------
# Submitting the job to casper (or other NCAR DAV clusters?) requires using slurm.

# Important things to know about slurm:
#
# sinfo     information about the whole slurm system
# squeue    information about running jobs
# sbatch    submitting a job
# scancel   killing a job
# scontrol  show job <jobID> specifications 
#           (-d for more details, including the script)

#==========================================================================

#SBATCH --job-name=repack_project
# Output standard output and error to a file named with 
# the job-name and the jobid.
#SBATCH -o %x_%j.eo 
#SBATCH -e %x_%j.eo 
# 80 members (1 type at a time)
#SBATCH --ntasks=80 
#SBATCH --time=04:00:00
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=raeder@ucar.edu
# #SBATCH --account=P86850054
#SBATCH --account=NCIS0006
#SBATCH --partition=dav
#SBATCH --ignore-pbs
# 
#-----------------------------------------

cd $SLURM_SUBMIT_DIR
# Needed for globus+ncar_py (but only in mv_to_campaign.csh?)
module load nco gnu 

# Needed for mpiexec_mpt:  
setenv MPI_SHEPHERD true
setenv date 'date --rfc-3339=ns'

echo "Preamble at "`date`

if (! -f CaseStatus) then
   echo "ERROR: this script must be run from the CESM CASEROOT directory"
   exit 1
endif

setenv CASEROOT $cwd
# Orig
set CASE           = $CASEROOT:t
# CASE is just used in the globus tranfer comment, 
# not in file name creation, so I can specify:
# set CASE           = 2012_2011SST

set ensemble_size  = `./xmlquery NINST_ATM   --value`

# Non-esp history output which might need to be processed.
# "components" = generic pieces of CESM (used in the archive directory names).
# "models" = component instance names (models, used in file names).
# "cpl" needs to be first (as in repack_st_arch.csh) so that the cmdfile template
# is created there and can be found by other components.
set components     = (cpl lnd  atm ice  rof)
set models         = (cpl clm2 cam cice mosart)
# set components     = (rof)
# set models         = (mosart)

# Default mode; archive 2 kinds of data.
# These can be turned off by editing or argument(s).
# Number of tasks required by each section (request in the slurm directives 
#     according to the max of the 'true's)
# set do_obs_space   = 1       (This doesn't take long; the whole esp/hist directory is sent to mv_to_campaign.csh)
# set do_history     = nens    (each file type is a separate, 80 task, cmdfile command)
# do_forcing is not needed because it can be handled the same as the 
# {other components}/hist directories.

set do_obs_space   = 'true'
set do_history     = 'true'

#--------------------------------------------
if ($#argv == 0) then
   # User submitted, independent batch job (not run by another batch job).
   # CASE could be replaced by setup_*, as is done for DART_config.
   # "project" will be created as needed (assuming user has permission to write there).
   # set project    = /glade/p/cisl/dares/Reanalyses/CAM6_2017
   set project    = /glade/p/nsc/ncis0006/Reanalyses/${CASE}
   set campaign   = /gpfs/csfs1/cisl/dares/Reanalyses/${CASE}
   set year  = 2017

   env | sort | grep SLURM

else if ($#argv == 1) then
   # Request for help; any argument will do.
   echo "Usage:  "
   echo "Before running this script"
   echo "    Run repack_st_archive.csh. "
   echo "    Log in to globus (see mv_to_campaign.csh for instructions)."
   echo "    From a casper window (but not 'ssh'ed to data-access.ucar.edu)"
   echo "    submit this script from the CESM CASEROOT directory. "
   echo "Call by user or script:"
   echo "   repack_project.csh project_dir campaign_dir [do_this=false] ... "
   echo "      project_dir    = directory where $CASE.dart.e.cam_obs_seq_final.$date.nc are"
   echo "      campaign_dir   = directory where $CASE.dart.e.cam_obs_seq_final.$date.nc are"
   echo "      do_this=false  = Turn off one (or more) of the archiving sections."
   echo "                       'this' = {obs_space,hist}."
   echo "                       No quotes, no spaces."
   exit

else
   # Script run by another (batch) script or interactively.
   set project  = $1
   set campaign = $2
   # These arguments to turn off parts of the archiving must have the form do_obs_space=false ;
   # no quotes, no spaces.
   if ($?3) set $3
   if ($?4) set $4
   if ($?5) set $5
endif

cd $project
pwd

#==========================================================================
# Where to find files, and what to do with them
#==========================================================================
# 1) Obs space diagnostics.
#    Generated separately using diags_rean.csh

echo "------------------------"
if ($do_obs_space == true) then
   cd esp/hist
   echo " "
   echo "Location for obs space is `pwd`"

   # Obs space files are already compressed.

   # mv_to_campaign.csh uses 'transfer --sync_level mtime'
   # so the whole esp/hist directory can be specified,
   # but only the files which are newer than the CS versions will be transferred.

   ${CASEROOT}/mv_to_campaign.csh $CASE $year ${project}/esp/hist/  \
                                             ${campaign}/esp/hist
   cd ../..
   
endif

#--------------------------------------------

# 2) CESM history files

echo "------------------------"
if ($do_history == true) then
   echo "There are $#components components (models)"
   echo " "
   set m = 1
   while ($m <= $#components)
      if (! -d $components[$m]/hist) then
         echo "Skipping $components[$m] because there are no history files"
         @ m++
         continue
      endif 

      cd $components[$m]/hist

      if ($components[$m] == 'cpl') then
         set types = ( ha2x1d hr2x ha2x3h ha2x1h ha2x1hi )
         echo "Location for history is `pwd`"
      else
         ls 0001/*h0* >& /dev/null
         if ($status != 0) then
            echo "Skipping $components[$m]/hist"
            @ m++
            continue
         endif

         echo "Location for history is `pwd`"
         
         set types = ()
         set n = 0
         while ($n < 10)
            ls 0001/*h${n}* 
            if ($status != 0) then
               @ n = $n - 1
               break
            endif

            set types = ($types h$n)
            @ n++
         end
      endif

      set t = 1
      while ($t <= $#types)
         if ($models[$m] == 'cam' && $t == 1) then
            # If cam.h0 ends up with more than PHIS, comment this out
            # and fix the h0 purging in the state_space section.
            # Actually; skip cam*.h0. because of the purging done by assimilate.csh.
#             sed -e "s#TYPE#h$type#g" ${cmds_template} | grep _0001 >> ${mycmdfile}
#             @ tasks = $tasks + 1
            @ t++
            continue
         else
            echo "----------------------"
            echo "$models[$m] $types[$t]"
         endif

         # Make a cmd file to compress this year's history file(s) in $project.
         if (-f cmdfile) mv cmdfile cmdfile_prev
         touch cmdfile

         set tasks = 0
         set i = 1
         while ($i <= $ensemble_size)
            set NINST = `printf %04d $i`
# Orig
            set yearly_file = ${CASE}.$models[$m]_${NINST}.$types[$t].${year}.nc
# Kluge for 2012_2011SST set yearly_file = $CASEROOT:t.$models[$m]_${NINST}.$types[$t].${year}.nc

            if (-f ${NINST}/${yearly_file}) then
               echo "gzip ${NINST}/${yearly_file} &> $types[$t]_${NINST}.eo " >> cmdfile
               @ tasks++
            endif
            @ i++
         end

         if (-z cmdfile) then
            echo "WARNING: cmdfile has size 0, hopefully because type $types[$t] was already done"
            @ t++
            continue
         endif

         echo "   history mpirun launch_cf.sh starts at "`date`
         mpirun -n $tasks ${CASEROOT}/launch_cf.sh ./cmdfile
         set mpi_status = $status
         echo "   history mpirun launch_cf.sh ends at "`date`
      
         ls *.eo > /dev/null
         if ($status == 0) then
            grep gzip *.eo >& /dev/null
            # grep failure = gzip success = "not 0"
            set gr_stat = $status
         else
            echo "No eo files = failure of something besides g(un)zip."
            echo "   History file gzip mpi_status = $mpi_status"
            set gr_stat = 0
         endif
      
         if ($mpi_status == 0 && $gr_stat != 0) then
            rm cmdfile *.eo
         else
            echo "ERROR in repackaging history files: See $components[$m]/hist/"\
                 'h*.eo, cmdfile'
            echo '      grep gzip *.eo  yielded status '$gr_stat
            exit 130
         endif

         @ t++
      end

      ${CASEROOT}/mv_to_campaign.csh $CASE $year ${project}/$components[$m]/hist/  \
                                                ${campaign}/$components[$m]/hist
 
      cd ../..

      @ m++
   end
endif

exit
#==========================================================================
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
