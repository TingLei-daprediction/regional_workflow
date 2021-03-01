#!/bin/sh 
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
elif [ "${jobpre}" = "regional_post_con" ]; then
  module purge
  echo "module load post"
#clt  module load post
  source ${module_dir}/post
elif [[ "${jobpre}" =~ "gsi" ]]; then
#clt  module purge
  module purge
  echo "module load regional_gsi"
#clt  module load regional_gsi
  source ${module_dir}/regional_gsi
else
  module purge
  echo "module load regional"
#clt  module load regional
  source ${module_dir}/regional
fi
module list

exec "$@"
