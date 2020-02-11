#!/bin/tcsh

set n = 1
while ($n <= 80)
   set nn = `printf %04d $n`

   mv f.e21.FHIST_BGC.f09_025.CAM6assim.011.cpl_${nn}.*.2011.nc \
      /glade/p/nsc/ncis0006/Reanalyses/f.e21.FHIST_BGC.f09_025.CAM6assim.011/cpl/hist/${nn}

   @ n++
end

