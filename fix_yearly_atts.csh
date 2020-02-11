#!/bin/csh
#
# This was developed to fix files which ended up with the wrong
# (or no) attributes due to the strange behavior of ncrcat --rec_apn,
# which is used to add monthly data to existing yearly files.
# When the yearly file doesn't yet exist, the command transfers
# its non-existent attributes to the output file
# and ignores the attributes in the file being added.
# Details are in $mac/.../f.e21.FHIST_BGC.f09_025.CAM6assim.011/ncrcat.crap
# and "notes".

# This is adapted from:
# http://nco.sourceforge.net/nco.html#Filters-for-ncks
# Copy/append metadata (not data) from variables in one file to variables 
# in a second file. When copying/subsetting/appending files (as opposed to 
# printing them), the copying of data, variable metadata, and global/group 
# metadata are now turned OFF by '-H', '-m', and '-M', respectively. This 
# is the opposite sense in which these switches work when printing a file. 
# One can use these switches to easily replace data or metadata in one 
# file with data or metadata from another:

#-----------------------------------------
#SBATCH --job-name=cp_atts_hist
#SBATCH -o %x_%j.eo 
#SBATCH -e %x_%j.eo 
# 80 members
# Each type is done as a separate cmdfile
#SBATCH --ntasks=80 
#SBATCH --time=00:20:00
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=raeder@ucar.edu
#SBATCH --account=P86850054
#SBATCH --partition=dav
#SBATCH --ignore-pbs
# 
#-----------------------------------------
#PBS  -N cp_atts_hist.csh
#PBS  -A NCIS0006
#PBS  -q regular
# #PBS  -q share
#PBS  -l select=5:ncpus=36:mpiprocs=36
# #PBS  -l select=1:ncpus=1:mpiprocs=1
#PBS  -l walltime=00:10:00
#PBS  -o cp_atts_hist.out
#PBS  -j oe 

# ------------------------------------------------------------------------------

set CASE      = f.e21.FHIST_BGC.f09_025.CAM6assim.011
set CASEROOT  = /glade/work/raeder/Exp/$CASE

set ORIGIN = /glade/p/nsc/ncis0006/Reanalyses/${CASE}/rof/hist
set atts_dir =  /glade/scratch/raeder/${CASE}/archive/rof/hist

set YEAR = 2013
set num_inst = 80

# --------------------------
# Environment and commands.
setenv MPI_SHEPHERD true
setenv date 'date --rfc-3339=ns'

cd $ORIGIN

# foreach type (ha2x3h ha2x1h ha2x1hi ha2x1d hr2x)
# foreach type (h1 h0 )
foreach type (h0 )
   echo "Starting $type at "
   $date

   if (-f cmdfile) mv cmdfile prev_cmdfile
   touch cmdfile

#    set atts_file = ${CASE}.cpl_0001.${type}.2014-01-01-00000.nc
#    set atts_file = ${CASE}.clm2_0001.${type}.2014-01-01-00000.nc
   set atts_file = ${CASE}.mosart_0001.${type}.2014-01.nc
   if (! -f ${atts_file}) then
      if (-f ${atts_dir}/${atts_file}.gz ) then    
         cp ${atts_dir}/${atts_file}.gz .
         gunzip ${atts_file}.gz
      else if (-f ${atts_dir}/${atts_file}) then
         cp ${atts_dir}/${atts_file} .
      else
         echo "ERROR: missing $atts_file"
         exit
      endif
   endif

   set tasks = 0
   set n = 1
   while ($n <= $num_inst)
      set NINST = `printf %04d $n`

      # set FILE = ${CASE}.clm2_${NINST}.${type}.${YEAR}.nc
      set FILE = ${CASE}.mosart_${NINST}.${type}.${YEAR}.nc

      # -A  append only variable attributes to the destination file.
      # -H  turn off copying of variables
      # -C  do not copy coordinate variables 
      # -v time_bnds  Must be included explicitly in order to get its attributes.
      
      echo " ncks -A -C -H ${atts_file} ${NINST}/${FILE} &> cp_atts_${n}.eo " >> cmdfile
      @ tasks ++

      @ n++
   end

   if ($?PBS_O_WORKDIR) then
      mpiexec_mpt -n $tasks ${CASEROOT}/launch_cf.sh ./cmdfile
      set mpi_status = $status
   else if ($?SLURM_SUBMIT_DIR) then
      mpirun      -n $tasks ${CASEROOT}/launch_cf.sh ./cmdfile
      set mpi_status = $status
   endif
   echo "mpi_status = $mpi_status"

   # Check the statuses?
   if ( -f cp_atts_1.eo ) then
      grep ncks *.eo
      # grep failure = cp_atts success = "not 0"
      set gr_stat = $status
   #    echo "gr_stat when eo file exists = $gr_stat"
   else
      # No eo files = failure of something besides g(un)zip.
      set gr_stat = 0
   #    echo "gr_stat when eo file does not exist = $gr_stat"
   endif

   if ($gr_stat == 0) then
      echo "ncks failed.  See .eo files with non-0 sizes"
      echo "Remove .eo files after failure is resolved."
      exit 197
   else
      # Compression worked; clean up the .eo files and cmdfile
      \rm -f *.eo  cmdfile
   endif

   echo "Ending $type at "
   $date
end


