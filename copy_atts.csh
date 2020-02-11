#!/bin/csh
#
# Last modification (aside from this comment) was 2019-11-20.
# This tranfers attributes from a single file to another,
# maybe as a test while fixing the ncrcat --rec_apn mess.

# This is adapted from:
# http://nco.sourceforge.net/nco.html#Filters-for-ncks
# Copy/append metadata (not data) from variables in one file to variables 
# in a second file. When copying/subsetting/appending files (as opposed to 
# printing them), the copying of data, variable metadata, and global/group 
# metadata are now turned OFF by '-H', '-m', and '-M', respectively. This 
# is the opposite sense in which these switches work when printing a file. 
# One can use these switches to easily replace data or metadata in one 
# file with data or metadata from another:

set CASE = f.e21.FHIST_BGC.f09_025.CAM6assim.011
set ORIGIN = /glade/p/nsc/ncis0006/Reanalyses/${CASE}/cpl/hist
set TEMPDIR = /glade/scratch/thoar/temp

set YEAR = 2013
set NINST = `printf %04d 80`
set FILE = ${CASE}.cpl_${NINST}.ha2x1d.$YEAR.nc

set DATAFILE = ${TEMPDIR}/nco/f.e21.FHIST_BGC.f09_025.CAM6assim.011.cpl_0080.ha2x1d.2014-01-01-00000.nc

cd ${TEMPDIR}

cp ${ORIGIN}/${FILE} .

ncks -A -C -H ${DATAFILE} ${FILE}

