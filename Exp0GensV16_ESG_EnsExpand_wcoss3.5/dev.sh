#!/bin/bash -l
set -x
#module load rocoto/1.2.4
. /usrx/local/prod/lmod/lmod/init/sh
set -x

module load impi/18.0.1
module load lsf/10.1

module use /gpfs/dell3/usrx/local/dev/emc_rocoto/modulefiles/
module load ruby/2.5.1 rocoto/1.2.4

rundir="/gpfs/dell6/emc/modeling/noscrub/Ting.Lei/dr-newESG-regional-workflow/regional_workflow/Exp0GensRocoto_ESG_EnsExpand_wcoss3.5"
rocotorun -v 10 -w $rundir/dev-GensExpand.xml -d $rundir/dev.db
