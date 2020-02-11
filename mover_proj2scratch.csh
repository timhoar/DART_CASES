#!/bin/tcsh

#PBS  -N mover_proj2scratch
#PBS  -A NCIS0006
#PBS  -q share
# Resources I want:
#    select=#nodes
#    ncpus=#CPUs/node
#    mpiprocs=#MPI_tasks/node
#PBS  -l select=1:ncpus=1:mpiprocs=1
#PBS  -l walltime=06:00:00
# Send email after a(bort) or e(nd)
#PBS  -m ae
#PBS  -M raeder@ucar.edu
# Send standard output and error to this file.
# It's helpful to use the $casename here.
#PBS  -o mover_proj2scratch.esp.eo
#PBS  -j oe 
#--------------------------------------------

#  Usage: edit this file to change source, destination, etc.
#         From /glade/p/nsc/ncis0006/Reanalyses/f.e21.FHIST_BGC.f09_025.CAM6assim.011/lnd/hist

# set year_mm  = 2011-07
set case     = f.e21.FHIST_BGC.f09_025.CAM6assim.011
set comp     = esp
set model    = esp
set proj_dir = "/glade/p/nsc/ncis0006/Reanalyses/${case}/${comp}/hist"
set scratch  = "/glade/scratch/raeder/${case}/archive/${comp}/hist/From_project"
# set file     = "${case}.cam_obs_seq_final.${year_mm}.tgz"

cd $proj_dir
echo "In $proj_dir"

# touch moved_2011-13.out

# set n = 1
set n = 2
# while ($n <= 80)
set save_dirs = `ls -d 201[1-5]*`
while ($n <= $#save_dirs)
   # set nn = `printf %04d $n`

   # set dest = ${scratch}/${nn}
   # if (! -d $dest) mkdir -p $dest

#    set cmnd = "tar -c -z -f ${proj_dir}/${file} "'*obs_seq*'"${year_mm}"'*'
   # cp ${nn}/${case}.${model}_${nn}.h*.201[1-3].nc.gz  $dest
   cp -r $save_dirs[$n] ${scratch}

   if ($status == 0) then
      # echo "Copied ${nn}/"'*.h*'".201[1-3].nc.gz to $dest" 
      echo "Copied $save_dirs[$n] to $scratch" 
   else
      # echo "ERROR: cp of $nn failed"
      echo "ERROR: cp of $save_dirs[$n] failed"
      exit
   endif

#    echo "$cmnd" >& tar_obs_seq.${year_mm}.log.$$

#    qcmd -A NCIS0006 -l walltime=0:30:00 -q share \
#         -l select=1:ncpus=1:mpiprocs=1 \
#         -- "$cmnd"  >>& tar_obs_seq.${year_mm}.log.$$

   @ n++
end
# 
