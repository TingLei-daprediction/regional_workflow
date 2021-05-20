set -eux

cwd=`pwd`
mpiifort -o  prep_for_regional_DA.x  -I${NETCDF_INCLUDES} -g -debug -traceback -check all -fp-stack-check   prep_for_regional_DA.F90   -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf #-I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5 -lm -lz
#$MPIIFORT -o  create_expanded_restart_files_for_DA.x   -I${NETCDF_INCLUDES}  create_expanded_restart_files_for_DA.F90 -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf #-I${HDF5INCLUDE} -L${HDF5LIB} -lhdf5_hl -lhdf5 -lm -lz

mpiifort -o move_DA_update_data.x  -I${NETCDF_INCLUDES} move_DA_update_data.F90 -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf
#mv a.out move_DA_update_data.x
#ifort -o create_expanded_restart_files_for_DA.x  $NETCDF_LDFLAGS $NETCDF_INCLUDE create_expanded_restart_files_for_DA.F90
mpiifort -o create_expanded_restart_files_for_DA.x    -I${NETCDF_INCLUDES}  create_expanded_restart_files_for_DA.F90  -L${NETCDF_LIBRARIES} -lnetcdff -lnetcdf



