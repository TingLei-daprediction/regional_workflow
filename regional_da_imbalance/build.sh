set -eux

##source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`
module unload NetCDF/4.5.0

#moduledir=/gpfs/dell6/emc/modeling/noscrub/Eric.Rogers/fv3lam_for_dellp3.5/sorc/regional_post.fd/modulefiles/post
moduledir=/gpfs/dell6/emc/modeling/noscrub/Ting.Lei/dr-new-regional-workflow/regional_workflow/modulefiles/wcoss_dell_p3.5
module use -a ${moduledir}
#module load v8.0.0-wcoss_dell_p3
module load regional_gsi

#module unload NetCDF/4.5.0
###module load NetCDF/3.6.3

#cltifort -g -traceback -fp-model precise -xAVX $NETCDF_INCLUDE $NETCDF_LDFLAGS prep_for_regional_DA.F90
#clt mv a.out prep_for_regional_DA.x

ifort -g -traceback -fp-model precise -xAVX $NETCDF_INCLUDE $NETCDF_LDFLAGS move_DA_update_data.F90
mv a.out move_DA_update_data.x

#clt ifort -g -traceback -fp-model precise -xAVX $NETCDF_INCLUDE $NETCDF_LDFLAGS create_expanded_restart_files_for_DA.F90
mv a.out create_expanded_restart_files_for_DA.x
