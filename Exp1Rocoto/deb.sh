#!/bin/bash -l
set -x


module load  rocoto/1.3.1
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t forecast_ens_firstguess_grp01  
exit
rocotoboot -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c 201910030000 -t chgres_fcstbndy_tm06  
exit
rocotostat -v 10 -w /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.xml -d /scratch2/NCEPDEV/fv3-cam/${USER}/dr-regional-workflow/regional_workflow/Exp1Rocoto/dev.db -c all

