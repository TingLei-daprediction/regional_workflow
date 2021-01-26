#!/bin/sh 
set -x -u -e
date
export HOMEfv3=${HOMEfv3:-"/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow"}
. ${HOMEfv3}/rocoto/machine-setup.sh
export machine=${target}
export machine=${machine:-$target}

if [ "$machine" = "wcoss_dell_p3" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
elif [ "$machine" = "wcoss_cray" ] ; then
  . /opt/modules/default/init/sh
elif [ "$machine" = "hera" ] ; then
  . /apps/lmod/lmod/init/sh
elif [ "$machine" = "jet" ] ; then
  . /apps/lmod/lmod/init/sh
elif [ "$machine" = "wcoss_dell_p3.5" ] ; then
  . /usrx/local/prod/lmod/lmod/init/sh
fi

module use ${HOMEfv3}/modulefiles/${machine}
module_dir=${HOMEfv3}/modulefiles/${machine}
jobpre=$(echo ${job} | cut -c1-17)

#clt if [ "${jobpre}" = "regional_forecast" ]; then
#cltorg     module load fv3
#cltorg    else
#cltorg    module load regional
#cltorg fi

if [[ "${jobpre}" =~ "forecast" ]]; then
  module purge
  echo "module load fv3"
   module load fv3
#clt  source ${module_dir}/fv3
elif [[ "${jobpre}" =~ "chg" ]]; then
  module purge
  echo "module load chgres_cube"
  module load chgres_cube 
elif [[ "${jobpre}" =~ "post" ]]; then
  module purge
  echo "module load post"
  module load post
#clt  source ${module_dir}/post
elif [[ "${jobpre}" =~ "gsi" ]]; then
#clt  module purge
  module load regional_gsi
  echo "module load regional_gsi"
#clt  source ${module_dir}/regional_gsi
else
  module purge
  echo "module load regional"
  module load regional
#clt  source ${module_dir}/regional
fi
module list
exec "$@"
exit

