# This file is for user convenience only and is not used by the model
# Changes to this file will be ignored and overwritten
# Changes to the environment should be made in env_mach_specific.xml
# Run ./case.setup --reset to regenerate this file
source /glade/u/apps/ch/opt/lmod/7.5.3/lmod/lmod/init/csh
module purge 
module load ncarenv/1.2 intel/17.0.1 esmf_libs mkl esmf-7.1.0r-defio-mpi-O mpt/2.19 netcdf-mpi/4.6.1 pnetcdf/1.11.0 ncarcompilers/0.4.1
setenv OMP_STACKSIZE 256M
setenv TMPDIR /glade/scratch/raeder
setenv MPI_TYPE_DEPTH 16
setenv MPI_IB_CONGESTED 1
setenv MPI_USE_ARRAY None
setenv MPI_LAUNCH_TIMEOUT 50
setenv MPI_IB_CONGEST 1
setenv MPI_VERBOSE 1
setenv MPI_VERBOSE2 1
setenv MPI_GROUP_MAX 1024
setenv MPI_COMM_MAX 16383
setenv TMPDIR /glade/scratch/raeder
setenv MPI_USE_ARRAY false