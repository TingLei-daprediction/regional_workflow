#!/bin/bash -l
set -x


module load  rocoto/1.3.1
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0Rocoto/dev-glbens-oneob.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp0Rocoto/dev.db -c 201912281200 -t analysis_tm00 
exit
