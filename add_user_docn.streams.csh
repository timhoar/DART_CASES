#!/bin/tcsh

# Add modified versions of CaseDocs/docn.streams into ./usr_docn.streams
# to fix the time offset error in the avhrr daily SSTICE files.
# Tim says that +12 hours is the right amount,
# despite the muddled documentation on the CIME web site.

# WARNING; changes to the SSTICE pathname in env_run.xml
#          will be ignored as long as these files exist.
#          Either change the path name in these files
#          or move them out of the way, change env_run.xml,
#          run preview_namelist, and rerun this script.

# mkdir User_docn.streams_offset12h

set n = 1
while ($n <= 80)
   set nn = `printf %04d $n`
#    mv user_docn.streams.txt.prescribed_${nn} User_docn.streams_offset12h

   sed -e "s#      43200#      0#" CaseDocs/docn.streams.txt.prescribed_${nn} \
                               >   user_docn.streams.txt.prescribed_${nn}
   @ n++
end
