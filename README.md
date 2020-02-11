# DART_CASES
DART CASE directories from CESM experiments.

This is a way for us to curate what happens during the continued cycling of a CESM experiment.
Some (most?) things are expected to stay static, but better to be safe than sorry.

There is a complication that arises from trying to create a git directory
from an existing CESM CASE directory, and there is also a complication that
arises from trying to create a CESM CASE directory from an existing git directory.

The following strategy is based on the fact the 'master' branch of the git repository
should be empty and each experiment/case will be a unique branch name that will reflect
the CESM 'case' name.

The strategy is:

1. create the CESM CASE in the usual way
2. _clone_ the git repository into a temporary directory ... maybe named **bob**  . You should get a branch called _master_ which is (hopefully) empty except for the (hidden) git administration files and this README.
3. make a new git _branch_ in **bob** ... with the same name as the CASE.  In the example below, the use of <your_casename> is context-sensitive. We are trying to make a git branch with the same name as the CESM case directory, so sometimes <your_casename> refers to a directory, sometimes it refers to a git branch.
4. copy everything from the CESM CASE to **bob**
5. move the CESM CASE directory _out of the way_  ... maybe call it **backup**
6. rename **bob** to be the original CESM CASE directory name
7. compare the new CESM CASE directory with **backup**
8. add files to the local git repository - this should be on the branch that matches your CASE. You can confirm with _git status_
9. commit them to the local git repository
10. push the contents of the local git repository back to GitHub. When you cloned the repository in Step 2,
you automatically get a _remote_ called _origin_ but the GitHub repository has no knowledge of your new branch, so there is a special syntax for that.
11. delete **backup** - or at least make it readonly to prevent you from actually using it.

```
example[1]% cd cases/<your_casename>

example[-]% cd ..

example[2]% git clone git@github.com:NCAR/DART_CASES.git bob
Cloning into 'bob'...
remote: Enumerating objects: 6, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 6 (delta 1), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (6/6), done.
Resolving deltas: 100% (1/1), done.

example[-]% cd bob
example[3]% git checkout -b <your_casename>
example[-]% cd ..

example[4]% rsync -av <your_casename>/ bob/
sending incremental file list
./
.case.run
.env_mach_specific.csh
.env_mach_specific.sh
...

example[5]% mv <your_casename> backup

example[6]% mv bob <your_casename>

example[7]% <satisfy yourself these directories are 'identical' - caveat the git administration files>

example[-]% cd <your_casename>

example[8]% git add <whatever_files_you_want>

example[9]% git commit

example[10]% git push -u origin <your_casename>

example[-]% cd ..

example[11]% rm -rf backup
```
