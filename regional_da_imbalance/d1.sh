set -eux

cwd=`pwd`
setupfile="/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-regional-workflow/regional_workflow/rocoto/machine-setup.sh"
source $setupfile
#moduledir=/gpfs/hps3/emc/meso/save/emc.campara/fv3sarda/regional_workflow/sorc/regional_post.fd/modulefiles/post
modulefile=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-GFSV16-regional-workflow/regional_workflow/modulefiles/hera/fv3
source $modulefile
MPIIFORT=/apps/intel/compilers_and_libraries_2018/linux/mpi/intel64/bin/mpiifort
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_LIBRARIES}:/apps/hdf5/1.10.6/intel_seq/18.0.5/lib
##ftn -g -traceback -fp-model precise -xAVX -I/include prep_for_regional_DA.F90
#ifort -o prep_for_regional_DA.x $NETCDF_LDFLAGS   prep_for_regional_DA.F90
HDF5INCLUDE=/apps/hdf5/1.10.6/intel/18.0.5/include
HDF5LIB=/apps/hdf5/1.10.6/intel/18.0.5/lib
echo "xx " $NetCDF_LIBRARIES
#$MPIIFORT  -I${NETCDF_INCLUDES}  prep_for_regional_DA.F90 -I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5   -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf #-I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5 -lm -lz
$MPIIFORT -o prep_for_regional_DA.x  -I${NETCDF_INCLUDES}  prep_for_regional_DA.F90  -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf -I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5 -lm -lz
$MPIIFORT -o  create_expanded_restart_files_for_DA.x  -I${NETCDF_INCLUDES}   create_expanded_restart_files_for_DA.F90  -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf -I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5 -lm -lz
exit

