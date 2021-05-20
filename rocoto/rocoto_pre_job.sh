#!/bin/sh 
cmdline="$@"
set -x -u -e
date
export HOMEfv3=${HOMEfv3:-"/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow"}
. ${HOMEfv3}/rocoto/machine-setup.sh
export machine=${target}

if [ "$machine" = "wcoss_dell_p3" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
elif [ "$machine" = "wcoss_cray" ] ; then
  . /opt/modules/default/init/sh
elif [ "$machine" = "hera" ] ; then
  . /apps/lmod/lmod/init/sh
elif [ "$machine" = "jet" ] ; then
  . /apps/lmod/lmod/init/sh
fi

module use ${HOMEfv3}/modulefiles/${machine}
module_dir=${HOMEfv3}/modulefiles/${machine}
jobpre=$(echo ${job} | cut -c1-17)
if [[ "${jobpre}" =~ "forecast" ]]; then
  module purge
  echo "module load fv3"
#cltorg   module load fv3
  source ${module_dir}/fv3
elif [[ "${jobpre}" =~ "post" ]]; then
  module purge
  echo "module load post"
#clt  module load post
  source ${module_dir}/post
elif [[ "${jobpre}" =~ "ioda" ]]; then
  module purge
  echo "module load ioda_module"
#clt  module load post
  source ${module_dir}/ioda_module
elif [[ "${jobpre}" =~ "jedianl" ]]; then
  module purge
  echo "module load jedi_anl_complete"
#clt  module load post
  source ${module_dir}/jedi_anl_complete
elif [[ "${jobpre}" =~ "gsi" ]]; then
#clt  module purge
  module purge
  echo "module load regional_gsi"
#clt  module load regional_gsi
  source ${module_dir}/regional_gsi
elif [[ "${jobpre}" =~ "enkf" ]]; then
  module purge
  echo "thinkdeb0"
  echo "$@"
  echo "module load enkf_module"
  source ${module_dir}/enkf_module
echo "thinkdeb1"
echo "$@"
elif [[ "${jobpre}" =~ "chg" ]]; then
  module purge
  echo "module load chgres_cube"
  source ${module_dir}/chgres_cube
else
  module purge
  echo "module load regional"
#clt  module load regional
  source ${module_dir}/regional
fi
module list
echo "thinkdeb"
echo $@
exec $cmdline 
