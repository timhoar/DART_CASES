
> Thu Feb 13 10:16:02 MST 2020
> TJH:	I decided to document the branch and version of CIME that 
> 	is being used for the reanalysis experiment.
> 	The following is the CIME directory: 

```
0[1863] cheyenne1:/<3>Exp/f.e21.FHIST_BGC.f09_025.CAM6assim.011 > cd /glade/work/raeder/Models/cesm2_1_relsd_m5.6
Directory: /glade/work/raeder/Models/cesm2_1_relsd_m5.6
0[1864] cheyenne1:/<3>Models/cesm2_1_relsd_m5.6 > git status
On branch cesm2_1_forcing_rean
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	cesm_branches_2019-3-13
	checkout_externals.out
	checkout_externals_def_cime.out

nothing added to commit but untracked files present (use "git add" to track)
```

> And this is the head of the logs from that directory:

```
commit dab62ed8bbbadc5aa5a348a104a4df0c92129ed6
Author: kdraeder <raeder@ucar.edu>
Date:   Mon Dec 17 14:23:58 2018 -0700

    Changed cime to https://github.com/kdraeder/cime.git/cime_reanalysis_2019.

commit dfa6a46a0b7d50485825aa505712dbd056f50f97
Author: Chris Fischer <fischer@ucar.edu>
Date:   Tue Dec 4 11:50:04 2018 -0700

    Use cime5.6.10_cesm2_1_rel_06 external
```
