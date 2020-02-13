#!/bin/csh

# 'copy' can be any of
# CopyMetaData =
#  "Nposs                           ",   # possible observations
#  "Nused                           ",   # actually used
#  "NbadQC                          ",   # rejected because of qc (both NCEP and DART)
#  "NbadIZ                          ",   # rejected because too far outside the distribution
#  "NbadUV                          ",   # rejected because a U/V obs was missing the V/U obs
#  "NbadLV                          ",   # rejected because they are outside levels limits
#  "rmse                            ",   # root mean square error (automatically included in
                                         # plot_rmse_xxx_{evolution,profile}
#  "bias                            ",   # bias (automatically included in plot_bias_xxx_profile
#  "spread                          ",   # spread of just the ensemble 
#  "totalspread                     " ;  # spread of combined ensemble and obs error
# 
# BUT only do combined plots for Copies that have the same magnitude.
# Combining plot_rmse_xxx_profile for Nused (O(1000)) causes the rmse (O(1)) curve to be
#    a straight line on the y(level) axis
# And copystring = 'Nused'  appears on most of the plots anyway, so don't bother

# In the trunk, after 2015/6, there's a new optional argument to plot_rmse_xxx_profile:
# varargin, which gets parsed into 
# disp(['fname   : ', p.Results.fname])
# disp(['copy    : ', p.Results.copy])
# disp(['obsname : ', p.Results.obsname])
#
# set DART = ~/Jamaica/DART
# addpath $DART/diagnostics/matlab

if (-e script.m) mv script.m script_prev.m
touch script.m
echo "fname = 'obs_diag_output.nc';"                  >> script.m
# echo "fname = 'obs_diag_output.GPS.nc';"              >> script.m

# foreach copy (totalspread )
 foreach copy (bias )
#foreach copy (spread )
# foreach copy (totalspread bias)
#  foreach copy (observation ens_mean)
   echo "copystring = '$copy';"                          >> script.m

   # foreach func (plot_rmse_xxx_norm_evolution plot_rmse_xxx_norm_profile)
   # foreach func (plot_rmse_xxx_evolution plot_rmse_xxx_profile)
    foreach func (plot_rmse_xxx_norm_profile)
   # foreach func (plot_rmse_xxx_evolution )
      # usual: 
      echo "$func(fname,copystring,'MarkerSize',6)"         >> script.m
      # one obs type
      # echo "$func(fname,copystring,'obsname','RADIOSONDE_SPECIFIC_HUMIDITY','MarkerSize',6)"         >> script.m
#      echo "$func(fname,copystring,'obsname','RADIOSONDE_TEMPERATURE','MarkerSize',6)"         >> script.m
#      echo "$func(fname,copystring,'obsname','RADIOSONDE_HORIZONTAL_WIND','MarkerSize',6)"         >> script.m
   end

# This function can be called for only these 3 obs types (in this order!)
# in order to have profiles with natural units (which are too small to interpret at upper levels)
# and  unitless, which are normalized by the variable's average value so the upper levels
# can be interpreted.  The better solution is to plot the logs of the values,
# but that involves some tricky Matlab for the variables that span 0, like bias. 
#   foreach obs (AIRS_SPECIFIC_HUMIDITY RADIOSONDE_SPECIFIC_HUMIDITY GPSRO_REFRACTIVITY)
#   foreach obs (GPSRO_REFRACTIVITY) 
# > > > This needs to be updated: "obs avg _____ pr = #####" ?
#                                 
#      echo "plot_rmse_xxx_profile(fname,copystring,'obsname','$obs','MarkerSize',6)" >> script.m
#   end
 end
 echo "exit"                            >> script.m

matlab -nodesktop -nosplash -r script >&! matlab_nc.out
# matlab -nojvm -nosplash -r script >&! matlab_nc.out

# Archive all of the output.
# Useful path name fragments as seen from the Diags... directory
set full = `pwd`
set diag_name = $full:t
#set exp_full  = `dirname $full`
#set exp_name  = $exp_full:t
#set case_full = `dirname $exp_full`
#set case_name = $case_full:t
#set destin = ${case_name}/$exp_name

# cd ..
# tar -z -c -f ${diag_name}.tgz ${diag_name}

exit

