#!/bin/sh --login
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
jobpre=$(echo ${job} | cut -c1-17)
if [ "${jobpre}" = "regional_forecast" ]; then
  module load fv3
elif [ "${jobpre}" = "regional_post_con" ]; then
  module load post
else
  module load regional
fi
#cltorg module load nco
module load nco-gnu-haswell/4.4.4
module list

exec "$@"
