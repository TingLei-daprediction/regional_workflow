set -eux

cwd=`pwd`
setupfile="/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-regional-workflow/regional_workflow/rocoto/machine-setup.sh"
source $setupfile
#moduledir=/gpfs/hps3/emc/meso/save/emc.campara/fv3sarda/regional_workflow/sorc/regional_post.fd/modulefiles/post
modulefile=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-unified-workflow/ufs-srweather-app/env/build_hera_intel.env
source $modulefile
exit
MPIIFORT=/apps/intel/compilers_and_libraries_2018/linux/mpi/intel64/bin/mpiifort
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_LIBRARIES}
##ftn -g -traceback -fp-model precise -xAVX -I/include prep_for_regional_DA.F90
#ifort -o prep_for_regional_DA.x $NETCDF_LDFLAGS   prep_for_regional_DA.F90
HDF5INCLUDE=/apps/hdf5/1.10.6/intel_seq/18.0.5/include
HDF5LIB=/apps/hdf5/1.10.6/intel_seq/18.0.5/lib
$MPIIFORT  -I${NETCDF_INCLUDES}  prep_for_regional_DA.F90 -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf #-I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5 -lm -lz
exit

#ifort -o move_DA_update_data.x  $NETCDF_LDFLAGS $NETCDF_INCLUDE move_DA_update_data.F90
#mv a.out move_DA_update_data.x
#ifort -o create_expanded_restart_files_for_DA.x  $NETCDF_LDFLAGS $NETCDF_INCLUDE create_expanded_restart_files_for_DA.F90
ifort -o create_expanded_restart_files_for_DA.x   $NETCDF_INCLUDE create_expanded_restart_files_for_DA.F90



