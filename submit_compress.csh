#!/bin/tcsh

# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download

# $Id$

#==========================================================================
#
#SBATCH --job-name=compress
#SBATCH -o %x_%j.errout 
#SBATCH -e %x_%j.errout 
# 80 members
# restarts #SBATCH --ntasks=320 
# forcing files: 
#SBATCH --ntasks=405 
#SBATCH --time=02:00:00
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=raeder@ucar.edu
#SBATCH --account=NCIS0006
#SBATCH --partition=dav
#SBATCH --ignore-pbs
# 
#-----------------------------------------
#PBS  -N compress.csh
#PBS  -A NCIS0006
#PBS  -q share
# For hist: 5 * 80         = 400  / 36 = 12
# For dart: 1 + 2*(2 + 80) = 165  
#                            645 / 36 = 18
# For rest: 4 * 80         = 320 / 36 =  9
# For restarts:
#PBS  -l select=9:ncpus=36:mpiprocs=36
# #PBS  -l select=18:ncpus=36:mpiprocs=36
#PBS  -l walltime=00:20:00
#PBS  -o compress.out
#PBS  -j oe 

# Get CASE environment variables from the central variables file.
# This should make environment variables available in compress_hist.csh too.
cd /glade/work/raeder/Exp/f.e21.FHIST_BGC.f09_025.CAM6assim.011/
source data_scripts.csh

set comp_cmd      = 'gzip '
# set comp_cmd      = 'gzip -k'
set ymds          = 2014-12-01-00000
# set sets          = (cpl)
# Restarts
set sets          = (clm2 cpl cam cice)
# set types         = ( ha2x1d hr2x ha2x3h ha2x1h ha2x1hi )
set stages        = (none)

if ($?PBS_O_WORKDIR) then
   cd $PBS_O_WORKDIR
else if ($?SLURM_SUBMIT_DIR) then
   cd $SLURM_SUBMIT_DIR
endif

${data_CASEROOT}/compress.csh $comp_cmd $ymds "$sets" "$stages"
