# DART_CASES
DART CASE directories from CESM experiments.

This is a way for us to curate what happens during the continued cycling of a CESM experiment.
Some (most?) things are expected to stay static, but better to be safe than sorry.

There is a complication that arises from trying to create a git directory
from an existing CESM CASE directory, and there is also a complication that
arises from trying to create a CESM CASE directory from an existing git directory.
One strategy is to:

1. create the CESM CASE in the usual way
2. clone the git repository into a temporary directory ... maybe **bob**
3. copy everything from the CESM CASE to **bob**
4. move the CESM CASE directory _out of the way_  ... maybe call it **backup**
5. rename **bob** to be the original CESM CASE directory name
6. compare the new CESM CASE directory with **backup**
7. make a git branch ... with the CASE directory name, perhaps?
8. add bits to git, commit, push 
9. delete **backup** - or at least make it readonly to prevent you from actually using it.

```
example[1]% cd cases/existing_case_directory

example[-]% cd ..

example[2]% git clone git@github.com:NCAR/DART_CASES.git bob
Cloning into 'bob'...
remote: Enumerating objects: 6, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 6 (delta 1), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (6/6), done.
Resolving deltas: 100% (1/1), done.

example[3]% rsync -av existing_case_directory/ bob/
sending incremental file list
./
.case.run
.env_mach_specific.csh
.env_mach_specific.sh
...

example[4]% mv existing_case_directory backup

example[5]% mv bob existing_case_directory

example[6]% <satisfy yourself these directories are 'identical' - caveat the git administration files>

example[-]% cd existing_case_directory

example[7]% git checkout -b <your_casename>

example[8]% <git add/commit/push the useful bits>

example[-]% cd ..

example[9]% rm -rf backup
```
