#!/bin/tcsh


set file = f.e21.FHIST_BGC.f09_025.CAM6assim.011.st_archive.o359181

set run = /glade/scratch/raeder/f.e21.FHIST_BGC.f09_025.CAM6assim.011/run
set archive = /glade/scratch/raeder/f.e21.FHIST_BGC.f09_025.CAM6assim.011/archive
set case = f.e21.FHIST_BGC.f09_025.CAM6assim
set machine = chadmin1.ib0.cheyenne.ucar.edu

# Why does the first line print multiple times?
sed -e "1 i RUN     = $run\nARCHIVE = $archive\nCASE    = $case\nMACHINE = $machine\n\n" \
    -e "s#$run#RUN#;s#$archive#ARCHIVE#;s#$case#CASE#g;s#$machine#MACHINE#g" \
    -e "/out=/d;/err=/c err=no var" $file > $file.c

gzip $file.c

# This form worked outside of this script
# sed -e "s#$run#RUN#" $file
# This doesn't work anywhere.  I can't figure out how to print a $
# sed -e "s#$run#\$run#" $file
