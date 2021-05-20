set -eux

cwd=`pwd`
setupfile="/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow/rocoto/machine-setup.sh"
source $setupfile
#moduledir=/gpfs/hps3/emc/meso/save/emc.campara/fv3sarda/regional_workflow/sorc/regional_post.fd/modulefiles/post
modulefile=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow/modulefiles/hera/fv3
source $modulefile

##ftn -g -traceback -fp-model precise -xAVX -I/include prep_for_regional_DA.F90
##mv a.out prep_for_regional_DA.x

ifort  $NETCDF_LDFLAGS $NETCDF_INCLUDE move_DA_update_data.F90
mv a.out move_DA_update_data.x

