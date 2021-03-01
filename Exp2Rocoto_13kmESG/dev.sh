#!/bin/bash -l
set -x
#module load rocoto/1.2.4
module load rocoto/1.3.2


rundir=/scratch2/NCEPDEV/fv3-cam/Ting.Lei/dr-regional-workflow/regional_workflow/Exp2Rocoto_13kmESG
rocotorun -v 10 -w $rundir/dev.xml -d $rundir/dev.db
