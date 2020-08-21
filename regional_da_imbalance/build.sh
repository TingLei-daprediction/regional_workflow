set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

moduledir=/gpfs/hps3/emc/meso/save/emc.campara/fv3sarda/regional_workflow/sorc/regional_post.fd/modulefiles/post
module use -a ${moduledir}
module load v8.0.0-cray-intel

##ftn -g -traceback -fp-model precise -xAVX -I/include prep_for_regional_DA.F90
##mv a.out prep_for_regional_DA.x

ftn -g -traceback -fp-model precise -xAVX -I/include move_DA_update_data.F90
mv a.out move_DA_update_data.x
