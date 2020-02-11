#!/bin/tcsh

# CESM writes a job environment log file to ./logs for every *cycle*. 
# They differ by only the LID variable, which is contained in the file names.
# Compress this data by saving a whole file from each job,
# and the LID lines from the rest of the files.
# Then gzip the result.

cd logs
ls -1 run_environment.txt*[0-9] >! file.list
set num_files = `wc -l file.list`

# run_environment.txt.341262.chadmin1.ib0.cheyenne.ucar.edu.200119-121630

set jobprev = 0
set f = 1
while ( $f <= $num_files[1])
   set file = `sed -n ${f}p file.list`
   set jobid = `echo $file | cut -d '.' -f 3`

   if ($jobid == $jobprev) then
      grep LID $file >> $file_out
   else
      set file_out = run_environment.txt.${jobid}.all_cycles.$file:e
      cp $file $file_out

      # The previous job's file has all the info it's gonna get.
      gzip run_environment.txt.${jobprev}.all*  & 
      rm   run_environment.txt.${jobprev}.chad* & 
      set jobprev = $jobid
   endif
   
   @ f++
end

# Clean up the last job
gzip run_environment.txt.${jobprev}.all*  &
rm   run_environment.txt.${jobprev}.chad* &
wait

rm file.list
