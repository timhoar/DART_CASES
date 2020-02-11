#!/bin tcsh

# Extract a 'copy' of an obs type from 
# a time series of obs_diag_output.nc files.
# This resulting file was reformatted and used
# in a matlab script like 
#   $mac/f.e21.FHIST_BGC.f09_025.CAM6assim.011/
#   Linked_2016_surf_T_bias/RadTbias2010to2017_1to12.m

#SBATCH --job-name=bias_from_obs_seq_output
#SBATCH -o %x_%j.eo 
#SBATCH -e %x_%j.eo 
#SBATCH --ntasks=1 
#SBATCH --time=02:00:00
#SBATCH --account=NCIS0006
#SBATCH --partition=dav
#SBATCH --ignore-pbs

cd $SLURM_SUBMIT_DIR
module load nco gnu udunits

set year1 = 2011
set yearN = 2016
set mo1 = 1
set moN = 12
set copy = 'bias'
set copyi = 8
set obs = 'RADIOSONDE_TEMPERATURE'

set out_file = "${obs}_${copy}_${year1}-${yearN}_${mo1}-${moN}"
if (-f $outfile) then
   echo "ERROR: $outfile exists.  Move it or choose another name"
   exit
endif
# echo "year" > $out_file
touch $out_file
# echo "  Jan 3 regions" >> $out_file
# echo "  Feb 3 regions" >> $out_file
# echo "  ..." >> $out_file

set y = $year1
while ($y <= $yearN)
   echo $y >> $out_file
   set m = $mo1
   while ($m <= $moN)
      set mm = `printf %02d $m`
      set D = "Diags_NTrS_${year}-$mm"

      if (-f ${D}/obs_diag_output.nc) then
         ncks -F -v ${obs}_VPguess -d copy,$copyi -d plevel,1 ${D}/obs_diag_output.nc >! temp_vals
         if ($status != 0) then
            echo "NaN, NaN, NaN," >> $out_file
            @ m++
            continue
         endif

         set line = `grep -n data temp_vals | sed -e "s/://"`
         @ line_num = $line[1] + 2
         # This was hard: 
         # operate on line number line_num
         # substitute ',' for the trailing ; (escaped because it's a command separator) 
         # print it (p), but not any other lines (-n)
         sed -n -e "$line_num s# \;#,#p" temp_vals >> $out_file

      else
         echo "NaN, NaN, NaN," >> $out_file
      endif

      @ m++
   end
   @ y++
end

rm tempvals
