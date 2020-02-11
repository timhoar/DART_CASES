#!/bin/tcsh 

set rean_scr = /glade/u/home/raeder/DART/reanalysis/models/cam-fv/shell_scripts/cesm2_1
echo '' >! not_in_DART

# listed according to last mod time, 2020-1-28
foreach f ( \
   repack_st_arch.csh \
   purge.csh \
   pre_purge_check.csh \
   repack_project.csh \
   mv_to_campaign.csh \
   assimilate.csh \
   bias_from_obs_seq_output.csh \
   repack_hwm.csh \
   repack_st_arch_tidy_mess.csh \
   mover_proj2scratch.csh \
   mover.csh \
   compress_hist.csh \
   compress.csh \
   fix_yearly_atts.csh \
   repack_st_arch-thru2013-12.csh \
   copy_atts.csh \
   assim_post_filter.csh \
   compress_cs.csh \
   chng_hybrid2branch.csh \
   mv_2012-09-17-00000.csh \
   backup_manually.csh \
   call_mv_to_cs.csh \
   tar_obs_seq_qcmd.csh \
   assim.csh \
   no_assimilate.csh \
   diags_batch.csh )
   if (-f $rean_scr/$f) then
      diffuse $f $rean_scr/$f
   else 
      echo $f >> not_in_DART
   endif
end   
