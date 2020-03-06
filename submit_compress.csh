UNTESTED

#!/bin/tcsh

# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download

# $Id$

#PBS  -N compress.csh
#PBS  -A your_account
#PBS  -q premium
# For restarts:
# #PBS  -l select=9:ncpus=36:mpiprocs=36
# For hist: 5 * 80         = 400  / 36 = 12
# For dart: 1 + 2*(2 + 80) = 165  
#                            645 / 36 = 18
# For rest: 4 * 80         = 320 / 36 =  9
#PBS  -l select=18:ncpus=36:mpiprocs=36
#PBS  -l walltime=00:20:00
#PBS  -o compress.out
#PBS  -j oe 

# Get CASE environment variables from the central variables file.
# This should make environment variables available in compress_hist.csh too.
source your_caseroot/data_scripts.csh

set comp_cmd      = 'gzip -k'
set ymds          = 2010-07-17-64800
set sets          = (cpl)
# set types         = ( ha2x1d hr2x ha2x3h ha2x1h ha2x1hi )
set stages        = (none)

if ($?PBS_O_WORKDIR) then
   cd $PBS_O_WORKDIR
else if ($?SLURM_SUBMIT_DIR) then
   cd $SLURM_SUBMIT_DIR
endif

${data_CASEROOT}/compress.csh $comp_cmd $ymds "$sets" "$stages"'
