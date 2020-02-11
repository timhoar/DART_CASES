#!/bin/tcsh

# RUN ON casper.

# Monitor repack_st_arch.csh to see how much disk space it requires.
# This was run while archiving 2016-11, so yearly files are almost full sized.

# From the 2016-11 test it looks like I need 1 Tb more than current usage
# in order to run this.  That's assuming that processing the cpl hist files
# is first, after which lots of space is freed up.
# If it's not, the lnd history files needs almost 3 Tb.

set freq = 15

touch repack_hwm.out
echo "--------------------------------" >> repack_hwm.out

set again = true
while ($again == 'true')
   squeue  -u raeder | grep 'repack'
   if ($status != 0) then
      echo "repack is done.  Exiting"
      exit
   endif

   date >> repack_hwm.out
   gladequota | grep ncis0006 >> repack_hwm.out
   echo ' '

   sleep $freq

end
